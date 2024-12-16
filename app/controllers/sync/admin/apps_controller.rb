module Sync
  class Admin::AppsController < Admin::BaseController
    before_action :set_app, only: [:show, :edit, :key, :update, :destroy]

    def index
      q_params = {}
      q_params.merge! params.permit(:id, :type, :appid)

      @apps = App.default_where(q_params).order(id: :desc).page(params[:page])
    end

    def create
      @app = App.find_or_initialize_by(appid: app_params[:appid])
      @app.assign_attributes app_params
    end

    private
    def set_app
      @app = App.find(params[:id])
    end

    def app_params
      params.fetch(:app, {}).permit(
        :type,
        :name,
        :appid,
        :secret,
        :base_url
      )
    end

  end
end
