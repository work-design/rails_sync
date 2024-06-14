module Sync
  class ItemsController < BaseController
    skip_forgery_protection only: [:create]

    def index
      @items = Item.none.page(params[:page])
    end

    def create
      raw_params.each do |record_name, columns|
        record = Record.find_or_initialize_by(external_record_name: record_name)
      end

      head :ok
    end

  end
end
