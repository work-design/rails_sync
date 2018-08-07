require 'the_sync/engine'
require 'the_sync/config'

require 'the_sync/active_record'
require 'the_sync/adapter'

module TheSync
  mattr_accessor :synchro_types do
    []
  end

  def self.options
    @options ||= Rails.application.config_for('the_sync').with_indifferent_access
  end

end
