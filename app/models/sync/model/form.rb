# frozen_string_literal: true

module Qingflow
  module Model::Form
    extend ActiveSupport::Concern

    included do
      attribute :title, :string
      attribute :column_name, :string
      attribute :record_name, :string
      attribute :display, :boolean
      attribute :primary, :boolean
      attribute :modeling, :boolean
      attribute :foreign_key, :string

      belongs_to :app

      belongs_to :meta_model, class_name: 'Com::MetaModel', foreign_key: :record_name, primary_key: :record_name, optional: true
      belongs_to :meta_column, class_name: 'Com::MetaColumn', optional: true

      scope :display, -> { where(display: true) }
      scope :primary, -> { where(primary: true) }
      scope :modeling, -> { where(modeling: true) }

      before_validation :sync_application, if: -> { parent.present? || parent_id_changed? }
    end

    def sync_application
      self.application = parent.application if parent
    end

  end
end