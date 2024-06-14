# frozen_string_literal: true

module Sync
  module Model::Form
    extend ActiveSupport::Concern

    included do
      attribute :name, :string
      attribute :column_name, :string
      attribute :record_name, :string
      attribute :external_column_name, :string
      attribute :external_record_name, :string
      attribute :display, :boolean
      attribute :primary, :boolean
      attribute :modeling, :boolean

      belongs_to :organ, class_name: 'Org::Organ', optional: true
      belongs_to :record

      belongs_to :meta_model, class_name: 'Com::MetaModel', foreign_key: :record_name, primary_key: :record_name, optional: true
      belongs_to :meta_column, class_name: 'Com::MetaColumn', optional: true

      scope :display, -> { where(display: true) }
      scope :primary, -> { where(primary: true) }
      scope :modeling, -> { where(modeling: true) }

      before_validation :sync_organ, if: -> { new_record? || record_id_changed? }
      before_validation :sync_app, if: -> { parent.present? || parent_id_changed? }
    end

    def sync_organ
      self.organ_id = record.organ_id if record
    end

    def sync_app
      self.app = parent.app if parent
    end

  end
end