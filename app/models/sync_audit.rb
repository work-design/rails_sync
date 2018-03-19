class SyncAudit < ApplicationRecord
  serialize :audited_changes, Hash

  belongs_to :operator, polymorphic: true

end
