# frozen_string_literal: true

module Sync
  module Model::Item
    extend ActiveSupport::Concern

    included do
      attribute :identifier, :string, index: true
      attribute :values, :json
      attribute :logs_count, :integer, default: 0
      attribute :source, :string

      belongs_to :organ, class_name: 'Org::Organ', optional: true
      belongs_to :record

      has_many :forms, primary_key: :record_id, foreign_key: :record_id
      has_many :logs

      before_validation :sync_organ, if: -> { new_record? || record_id_changed? }
      after_save_commit :sync_forms, if: -> { saved_change_to_values? }
    end

    def sync_organ
      self.organ_id = record.organ_id if record
    end

    def sync_forms

    end

    def answers_hash
      r = {}
      answers.each do |answer|
        if answer['values'].present?
          r[answer['queId']] = answer['values'][0]['value']
        elsif answer['tableValues'].present?
          r[answer['queId']] = answer['tableValues'].map do |table|
            table.map(&->(i){ [i['queId'], i['values'][0]['value']] }).to_h
          end
        end
      end

      r
    end

    def answers_with_name
      keys = available_forms
      answers_hash.transform_keys do |key|
        keys[key]
      end
    end

    def available_forms
      application.forms.where(queid: answers_hash.keys).pluck(:queid, :title).to_h
    end

    def record_hash
      _answers_hash = answers_hash
      application.record_names.transform_values do |v|
        [
          v.select(&:primary).map(&->(i){ [i.meta_column.column_name, _answers_hash[i.queid]] }).to_h,
          v.map(&->(i){ [i.meta_column.column_name, _answers_hash[i.queid]] }).to_h
        ]
      end
    end

    def migrate
      record_hash.each do |record_class, values|
        primary_attrs, attrs = values
        if primary_attrs.present?
          log = logs.build
          item = record_class.find_by(primary_attrs) || record_class.new(attrs)
          item.assign_attributes attrs
          begin
            item.save!
            log.related = item
          rescue ActiveRecord::RecordInvalid => e
            log.exception = e.detailed_message
            log.exception_backtrace = e.backtrace
          rescue => other
            log.exception = other.message
            log.exception_backtrace = other.backtrace
          ensure
            log.save
          end
        end
      end
    end

    def sync_item!
      r = application.app.api.apply(applyid)
      self.update answers: r['answers'] if r.key?('answers')
    end

  end
end