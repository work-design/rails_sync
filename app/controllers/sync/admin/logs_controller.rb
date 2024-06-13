module Sync
  class Admin::LogsController < Admin::BaseController
    before_action :set_app
    before_action :set_item

    def index
      @logs = @item.logs.page(params[:page])
    end

    private
    def set_app
      @app = App.find params[:app_id]
    end

    def set_item
      @item = @app.items.find params[:item_id]
    end

  end
end
