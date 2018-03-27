class AuditApplyJob < ActiveJob::Base
  queue_as :default

  def perform(synchro_type, action: ['update', 'insert', 'delete'])
    SyncAudit.synchro_apply(synchro_type, action: action)
  end

end
