module Sync
  class Admin::ItemsController < Admin::BaseController
    before_action :set_record
    before_action :set_item, only: [:show, :edit, :update, :destroy, :actions, :refresh]

    def index
      @items = @record.items.order(id: :desc).page(params[:page])
    end

    def sync
      @record.sync_items!
    end

    def refresh
      @item.sync_item!
    end

    private
    def set_record
      @record = Record.find params[:record_id]
    end

    def set_item
      @item = @record.items.find params[:id]
    end

  end
end
