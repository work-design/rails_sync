module Sync
  module Model::Audit
    extend ActiveSupport::Concern

    included do
      attribute :synchro_params, :json
      attribute :audited_changes, :json
      attribute :operation, :string
      attribute :note, :string
      attribute :state, :string
      attribute :apply_at, :datetime

      belongs_to :synchro, polymorphic: true, optional: true
      belongs_to :operator, polymorphic: true, optional: true
      belongs_to :destined

      enum :state, {
        init: 'init',
        applied: 'applied',
        finished: 'finished'
      }, default: 'init'

      enum :operation, {
        update: 'update',
        delete: 'delete',
        insert: 'insert'
      }, prefix: true
    end

    def apply_changes
      if self.operation_update?
        _synchro = self.synchro || synchro_model.find_by(synchro_params)
        _synchro.assign_attributes to_apply_params
        self.state = 'applied'
        self.synchro_id = _synchro.id
        self.class.transaction do
          _synchro.save!
          self.save!
        end
      elsif self.operation_delete? && self.synchro
        self.class.transaction do
          self.synchro.destroy!
          self.update! state: 'applied'
        end
      elsif self.operation_insert?
        _synchro = synchro_model.find_or_initialize_by(synchro_params)
        _synchro.assign_attributes to_apply_params
        self.class.transaction do
          _synchro.method(:create_or_update).super_method.call
          self.update! synchro_id: _synchro.id, state: 'applied'
        end
      end
    end

    def synchro_model
      @synchro_model ||= self.synchro_type.constantize
    end

    def to_apply_params
      x = {}
      audited_changes.each do |key, v|
        if synchro_model.columns_hash[key].type == :string
          x[key] = v[1].to_s
        else
          x[key] = v[1]
        end
      end

      x
    end

    class_methods do
      def synchro_types
        self.select(:synchro_type).distinct.pluck(:synchro_type).compact
      end

      def apply_callback(type, operation: ['update', 'delete', 'insert'])
        self.where(state: :applied, synchro_type: type, operation: operation).find_each do |sync|
          self.transaction do
            sync.synchro.respond_to?(:after_sync) && sync.synchro.after_sync
            sync.update! state: 'finished'
          end
        end
      end

      def apply_synchro(type, operation: ['update', 'delete', 'insert'])
        self.where(state: 'init', synchro_type: type, operation: operation).find_each do |sync_audit|
          begin
            sync_audit.apply_changes
          rescue SystemStackError, ActiveRecord::ActiveRecordError => e
            logger.warn e.message
          end
        end
      end
    end

  end
end
