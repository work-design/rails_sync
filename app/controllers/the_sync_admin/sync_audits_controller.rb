class TheSyncAdmin::SyncAuditsController < TheSyncAdmin::BaseController
  before_action :set_sync_audit, only: [:show, :edit, :update, :destroy]

  def index
    @sync_audits = SyncAudit.page(params[:page])
  end

  def new
    @sync_audit = SyncAudit.new
  end

  def create
    @sync_audit = SyncAudit.new(sync_audit_params)

    if @sync_audit.save
      redirect_to sync_audits_url, notice: 'Sync audit was successfully created.'
    else
      render :new
    end
  end

  def show
  end

  def edit
  end

  def update
    if @sync_audit.update(sync_audit_params)
      redirect_to sync_audits_url, notice: 'Sync audit was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @sync_audit.destroy
    redirect_to sync_audits_url, notice: 'Sync audit was successfully destroyed.'
  end

  private
  def set_sync_audit
    @sync_audit = SyncAudit.find(params[:id])
  end

  def sync_audit_params
    params.fetch(:sync_audit, {}).permit()
  end

end
