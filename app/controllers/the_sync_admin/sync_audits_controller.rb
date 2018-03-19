class TheSyncAdmin::SyncAuditsController < TheSyncAdmin::BaseController
  before_action :set_sync_audit, only: [:show, :apply, :destroy]

  def index
    q_params = params.permit(:synchro_type)
    @sync_audits = SyncAudit.default_where(q_params).page(params[:page])
    @synchro_types = TheSync.synchro_types | SyncAudit.synchro_types
  end

  def sync
    @synchro_model = params[:synchro_type].constantize
    @synchro_model.cache_all_diffs

    redirect_to admin_sync_audits_url, notice: 'Sync Run successfully '
  end

  def show
  end

  def apply
    @sync_audit.apply_changes
    redirect_to admin_sync_audits_url, notice: 'Sync audit was successfully applied.'
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
