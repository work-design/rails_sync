require 'the_sync/adapter'
require 'the_sync/table'
require 'the_sync/analyzer'

module TheSync::ActiveRecord
  # source
  # source_client
  # dest_table
  def acts_as_sync(options = {})
    options[:dest_table] ||= self.table_name

    @syncs ||= []

    _mappings = options[:mapping].to_h

    if options[:only]
      _filter_columns = self.column_names & Array(options[:only])
    else
      _filter_columns = self.column_names - Array(options[:except])
    end

    options[:full_mappings] = _filter_columns.map { |column_name|
      next if column_name == primary_key
      if _mappings.key?(column_name)
        [column_name, _mappings[column_name]]
      else
        [column_name, column_name]
      end
    }.compact
    options[:dest_primary_key] = _mappings.key?(self.primary_key) ? _mappings[self.primary_key] : primary_key

    @my_columns = [primary_key] + options[:full_mappings].map { |col| col[0] }
    options[:dest_columns] = [options[:dest_primary_key]] + options[:full_mappings].map { |col| col[1] }

    TheSync.synchro_types << self.name
    @syncs << options
  end

  def analyze_diffs(*type)
    @syncs.each do |options|
      analyzer = TheSync::Analyzer.new(connection: self.connection, **options)
      analyzer.cache_all_diffs(*type)
    end
  end

end


ActiveSupport.on_load :active_record do
  extend TheSync::ActiveRecord
end