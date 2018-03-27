class SyncAudit < ApplicationRecord
  serialize :audited_changes, Hash

  enum state: {
    init: 'init',
    applied: 'applied'
  }

  enum action: {
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
    if self.action_update? && self.synchro
      self.synchro.assign_attributes to_apply_params
      self.class.transaction do
        self.synchro.save!
        self.update! state: 'applied'
      end
    elsif self.action_delete? && self.synchro
      self.class.transaction do
        self.synchro.destroy!
        self.update! state: 'applied'
      end
    elsif self.action_insert?
      synchro_model = self.synchro_type.constantize
      _synchro = synchro_model.find_or_initialize_by(id: self.synchro_id)
      _synchro.assign_attributes to_apply_params
      self.class.transaction do
        _synchro.save!
        self.update! state: 'applied'
      end
    end
  end

  def to_apply_params
    audited_changes.transform_values do |v|
      v[1]
    end
  end

  def self.synchro_types
    SyncAudit.select(:synchro_type).distinct.pluck(:synchro_type)
  end

  def self.synchro_apply(type, action: ['update', 'delete', 'insert'])
    SyncAudit.where(synchro_type: type, action: action).find_each do |sync_audit|
      begin
        sync_audit.apply_changes
      rescue SystemStackError, ActiveRecordError => e
        logger.warn e.message
      end
    end
  end

end
