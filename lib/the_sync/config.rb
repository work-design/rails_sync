require 'active_support/configurable'

module TheSync
  include ActiveSupport::Configurable

  configure do |config|
    config.xx = ''


  end

end