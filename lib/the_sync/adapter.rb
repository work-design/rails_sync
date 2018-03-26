module TheSync
  module Adapter
    extend self
    extend ActiveSupport::Autoload
    autoload :Base
    autoload :Mysql

    def lookup(name)
      const_get(name.to_s.camelize)
    end

    def adapter(adapter, options = {})
      @adapter_options = TheSync.options.fetch(adapter, {})
      adapter_class = lookup(@adapter_options[:adapter])
      @client = adapter_class.new(@adapter_options)

      #ObjectSpace.define_finalizer(self, self.class.method(:finalize))
    end

    def client
      adapter.client
    end

    def connection
      adapter.connection
    end

  end
end
