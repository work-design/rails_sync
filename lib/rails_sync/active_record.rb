require 'rails_sync/adapter'
require 'rails_sync/table'
require 'rails_sync/analyzer'

module RailsSync::ActiveRecord
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
    options[:primary_key] = Array(options[:primary_key] || self.primary_key).map { |i| i.to_s }
    options[:dest_primary_key] = Array(options[:dest_primary_key] || options[:primary_key]).map { |i| i.to_s }
    options[:dest_conditions] = options[:dest_conditions]
    options[:full_mappings] = _filter_columns.map { |column_name|
      next if options[:primary_key].include?(column_name)
      if _mappings.key?(column_name)
        [column_name, _mappings[column_name]]
      else
        [column_name, column_name]
      end
    }.compact

    options[:server_id] = self.server_id
    options[:analyzer] = RailsSync::Analyzer.new(record: self, **options)

    RailsSync.synchro_types << self.name
    @syncs << options
  end

  def server_id
    begin
      result = connection.query('select @@server_uuid')
    rescue
      result = connection.query('select @@server_id')
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
      next if !options[:primary_key].include?(self.primary_key) && type == 'delete'
      options[:analyzer].analyze_diffs(type)
    end
  end

  def cache_diffs(type = 'update')
    @syncs.flat_map do |options|
      next if !options[:primary_key].include?(self.primary_key) && type == 'delete'
      options[:analyzer].cache_diffs(type)
    end
  end

  def cache_all_diffs(*types)
    types = ['update', 'insert', 'delete'] if types.blank?
    types.each do |type|
      cache_diffs(type)
    end
  end

  def id_insert?
    @syncs.find { |i| i[:primary_key] == ['id'] }.present?
  end

  def prepare_sync
    @syncs.flat_map do |options|
      options[:analyzer].reset_temp_table unless options[:analyzer].same_server?
    end
  end

end

ActiveSupport.on_load :active_record do
  extend RailsSync::ActiveRecord
end