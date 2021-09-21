module Sync
  class Admin::AuditsController < Admin::BaseController
    before_action :set_audit, only: [:show, :apply, :destroy]

    def index
      q_params = params.permit(:synchro_type, :state, :operation)

      @audits = Audit.default_where(q_params).order(id: :desc).page(params[:page])
      @synchro_types = RailsSync.synchro_types.uniq | Audit.synchro_types
    end

    def sync
      @synchro_model = params[:synchro_type].constantize
      @synchro_model.cache_all_diffs
    end

    def batch
      AuditApplyJob.perform_later params[:synchro_type]
    end

    def apply
      @audit.apply_changes
    end

    def destroy
      @audit.destroy
    end

    private
    def set_audit
      @audit = Audit.find(params[:id])
    end

  end
end
