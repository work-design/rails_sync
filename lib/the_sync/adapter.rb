module TheSync
  module Adapter
    extend ActiveSupport::Autoload
    autoload :Base
    autoload :Mysql
    
    def self.lookup(name)
      const_get(name.to_s.camelize)
    end
    
    def self.adapter(adapter, options = {})
      @adapter_options = TheSync.options.fetch(adapter, {})
      adapter_class = lookup(@adapter_options[:adapter])
      @client = adapter_class.new(@adapter_options)
  
      #ObjectSpace.define_finalizer(self, self.class.method(:finalize))
    end
    
    def self.client
      adapter.client
    end
    
    def self.connection
      adapter.connection
    end
    
  end
end
