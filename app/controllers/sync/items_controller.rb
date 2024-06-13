module Sync
  class ItemsController < BaseController
    skip_forgery_protection only: [:create]

    def index
      @items = Item.none.page(params[:page])
    end

    def create

      head :ok
    end

  end
end
