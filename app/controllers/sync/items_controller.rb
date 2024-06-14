module Sync
  class ItemsController < BaseController
    skip_forgery_protection only: [:create]

    def index
      @items = Item.none.page(params[:page])
    end

    def create
      raw_params.each do |record_name, columns|
        record = Record.find_or_initialize_by(key: record_name)
        columns.each do |column|
          record.forms.find_or_initialize_by(external_column_name: column)
        end
        record.save
      end

      head :ok
    end

  end
end
