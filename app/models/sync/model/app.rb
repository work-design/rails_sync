# frozen_string_literal: true

module Qingflow
  module Model::App
    extend ActiveSupport::Concern

    included do
      attribute :name, :string
      attribute :appid, :string, index: true
      attribute :secret, :string
      attribute :access_token, :string
      attribute :access_token_expires_at, :datetime
      attribute :refresh_token, :string
      attribute :refresh_token_expires_at, :datetime

      belongs_to :organ, class_name: 'Org::Organ', optional: true

      has_many :forms
      has_many :display_forms, -> { display }, class_name: 'Form'
      has_many :items
    end

    def oauth_url
      h = {
        client_key: appid,
        response_type: 'code',
        scope: 'user_info',
        redirect_uri: Rails.application.routes.url_for(controller: 'douyin/apps')
      }

      "https://open.douyin.com/platform/oauth/connect?#{h.to_query}"
    end

    def access_token_valid?
      access_token_expires_at.acts_like?(:time) && access_token_expires_at > Time.current
    end

    def refresh_access_token
      r = api.token
      if r['accessToken']
        self.access_token = r['accessToken']
        self.access_token_expires_at = Time.current + r['expireTime'].to_i
        self.save
      else
        logger.debug "\e[35m  #{r}  \e[0m"
      end
    end

    def api
      return @api if defined? @api
      @api = Api::App.new(self)
    end

  end
end
