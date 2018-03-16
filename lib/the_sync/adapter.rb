module TheSync
  module Adapter
    extend ActiveSupport::Autoload
    autoload :Base
    autoload :Mysql
    
    def self.lookup(name)
      const_get(name.to_s.camelize)
    end
    
    def self.adapter(adapter, options = {})
      _options = TheSync.options[adapter]
      adapter_class = lookup(_options[:adapter])
      @client = adapter_class.new(_options)
      
      #ObjectSpace.define_finalizer(self, self.class.method(:finalize))
    end
    
    def self.client
      adapter.client
    end
    
  end
end
