module Sync
  class Admin::FormsController < Admin::BaseController
    before_action :set_app

    def index
      @forms = @app.forms.roots.page(params[:page])
    end

    def sync
      @app.sync_forms!
    end

    private
    def set_app
      @app = App.find params[:app_id]
    end

  end
end
