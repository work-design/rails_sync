require 'active_support/configurable'

module RailsSync
  include ActiveSupport::Configurable

  configure do |config|
    config.admin_class = 'AdminController'
  end

end
