module Sync
  class Admin::FormsController < Admin::BaseController
    before_action :set_record

    def index
      @forms = @record.forms.roots.page(params[:page])
    end

    def sync
      @record.sync_forms!
    end

    private
    def set_record
      @record = Record.find params[:record_id]
    end

  end
end
