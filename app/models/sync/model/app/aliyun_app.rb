module Sync
  module Model::App::AliyunApp
    extend ActiveSupport::Concern

    def api
      return @api if defined? @api
      @api = AliOcr.new(appid, secret)
    end

  end
end
