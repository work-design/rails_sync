require 'the_sync/adapter'
require 'the_sync/table'
require 'the_sync/analyzer'

module TheSync::ActiveRecord
  # source
  # source_client
  # dest_table
  def acts_as_sync(options = {})
    @syncs ||= []

    options[:dest_table] ||= self.table_name
    _mappings = Array(options.delete(:mapping)).to_h
    if options[:only]
      _filter_columns = self.column_names & Array(options.delete(:only))
    else
      _filter_columns = self.column_names - Array(options.delete(:except))
    end
    options[:primary_key] = (options[:primary_key] || self.primary_key).to_s
    options[:dest_primary_key] = _mappings.key?(options[:primary_key]) ? _mappings[options[:primary_key]] : options[:primary_key]
    options[:full_mappings] = _filter_columns.map { |column_name|
      next if column_name == options[:primary_key]
      if _mappings.key?(column_name)
        [column_name, _mappings[column_name]]
      else
        [column_name, column_name]
      end
    }.compact

    options[:analyzer] = TheSync::Analyzer.new(connection: self.connection, table_name: self.table_name, model_name: self.name, **options)
    options[:server_id] = server_id

    TheSync.synchro_types << self.name
    @syncs << options
  end

  def server_id
    begin
      result = connection.raw_connection.query('select @@server_uuid')
    rescue Mysql2::Error
      result = connection.raw_connection.query('select @@server_id')
    end
    _id = result.to_a.flatten.first
    if _id.is_a?(Hash)
      _id.values.first
    else
      _id
    end
  end

  def analyze_diffs(type = 'update')
    @syncs.flat_map do |options|
      options[:analyzer].analyze_diffs(type)
    end
  end

  def cache_diffs(type = 'update')
    @syncs.flat_map do |options|
      options[:analyzer].cache_diffs(type)
    end
  end

  def cache_all_diffs
    @syncs.flat_map do |options|
      options[:analyzer].cache_all_diffs
    end
  end

end

ActiveSupport.on_load :active_record do
  extend TheSync::ActiveRecord
end