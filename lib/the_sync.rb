require 'the_sync/engine'
require 'the_sync/config'

require 'the_sync/active_record'

module TheSync
  

  def self.options
    @options ||= Rails.application.config_for('the_sync')
  end

end
