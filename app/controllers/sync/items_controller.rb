module Sync
  class ItemsController < BaseController
    skip_forgery_protection only: [:create]
    before_action :set_app

    def index
      @items = Item.none.page(params[:page])
    end

    def create
      raw_params.each do |record_name, columns|
        record = @app.records.find_or_initialize_by(key: record_name)
        record.items.build(values: columns)
        record.save
      end

      head :ok
    end

    def update

    end

    private
    def set_app
      @app = App.first
    end

  end
end
