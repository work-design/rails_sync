module TheSync
  class Adapter
    extend ActiveRecord::ConnectionHandling
    thread_mattr_accessor :connection_handler, instance_writer: false

    def initialize(adapter, options = {})
      return @client if @client
      @adapter_options = TheSync.options.fetch(adapter, {})
      @client = self.class.establish_connection(@adapter_options)
    end

    def server_id
      begin
        result = connection.query('select @@server_uuid')
      rescue Mysql2::Error
        result = connection.query('select @@server_id')
      end
      _id = result.to_a.flatten.first
      if _id.is_a?(Hash)
        _id.values.first
      else
        _id
      end
    end

    def connection
      @client.connection
    end

    self.connection_handler = ActiveRecord::ConnectionAdapters::ConnectionHandler.new
  end
end
