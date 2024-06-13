module Sync
  class Admin::ItemsController < Admin::BaseController
    before_action :set_app
    before_action :set_item, only: [:show, :edit, :update, :destroy, :actions, :refresh]

    def index
      @items = @app.items.order(applyid: :desc).page(params[:page])
    end

    def sync
      @app.sync_items!
    end

    def refresh
      @item.sync_item!
    end

    private
    def set_app
      @app = App.find params[:app_id]
    end

    def set_item
      @item = @app.items.find params[:id]
    end

  end
end
