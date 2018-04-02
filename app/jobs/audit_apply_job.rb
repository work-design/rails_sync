class AuditApplyJob < ActiveJob::Base
  queue_as :default

  def perform(synchro_type, operation: ['update', 'insert', 'delete'])
    SyncAudit.apply_synchro(synchro_type, operation: operation)
    SyncAudit.apply_callback(synchro_type, operation: operation)
  end

end
