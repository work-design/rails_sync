class AuditApplyJob < ActiveJob::Base
  queue_as :default

  def perform(synchro_type, operation: ['update', 'insert', 'delete'])
    SyncAudit.synchro_apply(synchro_type, operation: operation)
  end

end
