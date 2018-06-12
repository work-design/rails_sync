class SyncAudit < ApplicationRecord
  serialize :audited_changes, Hash
  serialize :synchro_params, Hash

  enum state: {
    init: 'init',
    applied: 'applied',
    finished: 'finished'
  }

  enum operation: {
    update: 'update',
    delete: 'delete',
    insert: 'insert'
  }, _prefix: true

  belongs_to :synchro, polymorphic: true, optional: true
  belongs_to :operator, polymorphic: true, optional: true

  after_initialize if: :new_record? do
    self.state = 'init'
  end

  def apply_changes
    if self.operation_update?
      _synchro = self.synchro || synchro_model.find_by(synchro_params)
      _synchro.assign_attributes to_apply_params
      self.class.transaction do
        _synchro.save!
        self.update! state: 'applied'
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
        _synchro.save_sneakily!
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

  def self.synchro_types
    SyncAudit.select(:synchro_type).distinct.pluck(:synchro_type).compact
  end

  def self.apply_callback(type, operation: ['update', 'delete', 'insert'])
    SyncAudit.where(state: :applied, synchro_type: type, operation: operation).find_each do |sync|
      SyncAudit.transaction do
        sync.synchro.respond_to?(:after_sync) && sync.synchro.after_sync
        sync.update! state: 'finished'
      end
    end
  end

  def self.apply_synchro(type, operation: ['update', 'delete', 'insert'])
    SyncAudit.where(state: 'init', synchro_type: type, operation: operation).find_each do |sync_audit|
      begin
        sync_audit.apply_changes
      rescue SystemStackError, ActiveRecord::ActiveRecordError => e
        logger.warn e.message
      end
    end
  end

end
