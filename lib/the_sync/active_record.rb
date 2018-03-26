require 'the_sync/adapter'
require 'the_sync/table'
require 'the_sync/analyze'

module TheSync::ActiveRecord
  attr_reader :adapter
  # source
  # source_client
  # dest_table
  def acts_as_sync(options = {})
    options[:dest_table] ||= self.table_name

    _mappings = options[:mapping].to_h

    if options[:only]
      _filter_columns = self.column_names & Array(options[:only])
    else
      _filter_columns = self.column_names - Array(options[:except])
    end

    # 'source.table_name'
    @view_name = options[:dest].to_s + '_' + self.table_name

    @dest_table = options[:dest_table]
    @full_mappings = _filter_columns.map { |column_name|
      next if column_name == primary_key
      if _mappings.key?(column_name)
        [column_name, _mappings[column_name]]
      else
        [column_name, column_name]
      end
    }.compact
    @dest_pk = _mappings.key?(self.primary_key) ? _mappings[self.primary_key] : primary_key

    @my_columns = [primary_key] + @full_mappings.map { |col| col[0] }
    @dest_columns = [@dest_pk] + @full_mappings.map { |col| col[1] }

    @adapter = TheSync::Adapter.adapter(options[:dest])

    TheSync.synchro_types << self.name

    extend TheSync::Table
    extend TheSync::Analyze
  end


  def migrate_sync

  end

  def create_temp_table
    sql = "CREATE TABLE #{@view_name} (\n"
    sql << dest_sql_table(only: @dest_columns)
    sql << ")"
    sql << "ENGINE=FEDERATED\n"
    sql << "CONNECTION='#{adapter.connection}/#{@dest_table}';"

    connection.execute(sql)
  end

  def drop_temp_table
    sql = "DROP TABLE IF EXISTS `#{@view_name}`"

    connection.execute(sql)
  end

  def reset_temp_table
    drop_temp_table
    create_temp_table
  end

  def select_view(start: 0, finish: start + 1000)
    sql = <<~HEREDOC
      CREATE VIEW #{@view_name} \
      SELECT #{@dest_columns.join(',')} \
      FROM #{@dest_table} \
      WHERE #{@dest_pk} >= #{start} AND #{@dest_pk} <= #{finish}
      ORDER BY #{@dest_pk} ASC
    HEREDOC

    @adapter.client.query(sql)
  end

  def source_select
    query = table.project columns.map { |column| table[column] }
    query = query.where table[primary_key].in(ids)

    execute(query.to_sql).each
  end


end


ActiveSupport.on_load :active_record do
  extend TheSync::ActiveRecord
end