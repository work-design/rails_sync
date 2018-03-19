class SyncAudit < ApplicationRecord
  serialize :audited_changes, Hash

  enum state: {
    init: 'init',
    applied: 'applied'
  }

  belongs_to :synchro, polymorphic: true, optional: true
  belongs_to :operator, polymorphic: true, optional: true

  after_initialize if: :new_record? do
    self.state = 'init'
  end

  def apply_changes
    if self.synchro
      self.synchro.assign_attributes to_apply_params
      self.class.transaction do
        self.synchro.save!
        self.update! state: 'applied'
      end
    end
  end

  def to_apply_params
    audited_changes.transform_values do |v|
      v[1]
    end
  end


end
