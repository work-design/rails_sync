# frozen_string_literal: true

module Sync
  module Model::Record
    extend ActiveSupport::Concern

    included do
      attribute :name, :string
      attribute :key, :string

      belongs_to :organ, class_name: 'Org::Organ', optional: true
      belongs_to :app

      has_many :forms
      has_many :display_forms, -> { display }, class_name: 'Form'
      has_many :items

      before_validation :sync_organ, if: -> { new_record? || app_id_changed? }
    end

    def sync_organ
      self.organ_id = app.organ_id if app
    end

    def form(**options)
      app.api.form(key, **options)
    end

    def sync_forms!(**options)
      r = app.api.form(key, **options)
      init_form!(r['questionBaseInfos'])
    end

    def init_form!(ques)
      ques.each do |que|
        form = forms.find_or_initialize_by(queid: que['queId'])
        form.title = que['queTitle']
        form.que_type = que['queType']
        form.save
        init_child_form!(que['subQuestionBaseInfos'], form) if que['subQuestionBaseInfos'].present?
      end
    end

    def init_child_form!(ques, parent)
      ques.each do |que|
        form = parent.children.find_or_initialize_by(queid: que['queId'])
        form.title = que['queTitle']
        form.que_type = que['queType']
        form.save
      end
    end

    def sync_items!(**options)
      r = app.api.applies(key, **options)
      r['result'].each do |i|
        item = items.find_or_initialize_by(applyid: i['applyId'])
        item.answers = i['answers']
      end
      self.save
    end

    def record_names
      forms.includes(:meta_column).where.not(record_name: nil).group_by(&:record_name).transform_keys { |key| key.constantize }
    end

  end
end