class AuditApplyJob < ActiveJob::Base
  queue_as :default

  def perform()
    SyncAudit.synchro_apply params[:synchro_type]
  end

end
