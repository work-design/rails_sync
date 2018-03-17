require 'the_sync/adapter'
require 'the_sync/table'
require 'the_sync/analyze'

module TheSync::ActiveRecord
  attr_reader :adapter
  # source
  # source_client
  # source_table
  def acts_as_sync(options = {})

    _mappings = options[:mapping].to_h

    if options[:only]
      _filter_columns = self.column_names & Array(options[:only])
    else
      _filter_columns = self.column_names - Array(options[:except])
    end

    # 'source.table_name'
    @view_name = options[:source].to_s + '_' + self.table_name

    @source_table = options[:source_table]
    @full_mappings = _filter_columns.map { |column_name|
      next if column_name == primary_key
      if _mappings.key?(column_name)
        [column_name, _mappings[column_name]]
      else
        [column_name, column_name]
      end
    }.compact
    @source_columns = @full_mappings.map { |col| col[1] } + [primary_key]

    @adapter = TheSync::Adapter.adapter(options[:source])

    @source_pk = 'id'

    extend TheSync::Table
    extend TheSync::Analyze
  end


  def migrate_sync

  end

  def create_temp_table
    sql = "CREATE TABLE #{@view_name} (\n"
    sql << sql_table(only: @source_columns)
    sql << ")"
    sql << "ENGINE=FEDERATED\n"
    sql << "CONNECTION='#{adapter.connection}/#{@source_table}';"

    connection.execute(sql)
  end

  def select_view(start: 0, finish: start + 1000)
    sql = <<~HEREDOC
      CREATE TEMPORARY TABLE #{@view_name} \
      SELECT #{@source_columns.join(',')} \
      FROM #{@source_table} \
      WHERE #{@source_pk} >= #{start} AND #{@source_pk} <= #{finish}
      ORDER BY #{@source_pk} ASC
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