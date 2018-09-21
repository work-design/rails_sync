require 'rails_sync/engine'
require 'rails_sync/config'

require 'rails_sync/active_record'
require 'rails_sync/adapter'

module RailsSync
  mattr_accessor :synchro_types do
    []
  end

  def self.options
    @options ||= Rails.application.config_for('rails_sync').with_indifferent_access
  end

end
