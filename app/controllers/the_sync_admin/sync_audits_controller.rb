class TheSyncAdmin::SyncAuditsController < TheSyncAdmin::BaseController
  before_action :set_sync_audit, only: [:show, :apply, :destroy]

  def index
    @sync_audits = SyncAudit.page(params[:page])
  end

  def show
  end

  def apply
    @sync_audit.apply_changes
    redirect_to admin_sync_audits_url, notice: 'Sync audit was successfully destroyed.'
  end

  def destroy
    @sync_audit.destroy
    redirect_to admin_sync_audits_url, notice: 'Sync audit was successfully destroyed.'
  end

  private
  def set_sync_audit
    @sync_audit = SyncAudit.find(params[:id])
  end

end
