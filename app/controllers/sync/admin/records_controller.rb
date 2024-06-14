module Sync
  class Admin::RecordsController < Admin::BaseController
    before_action :set_app
    before_action :set_new_record, only: [:new, :create]

    def index
      @records = @app.records.page(params[:page])
    end

    private
    def set_app
      @app = App.find params[:app_id]
    end

    def set_new_record
      @record = @app.records.build(record_params)
    end

    def record_params
      params.fetch(:record, {}).permit(
        :key
      )
    end

  end
end
