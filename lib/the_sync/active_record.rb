require 'the_sync/adapter'
require 'the_sync/table'
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
    @view_name = options[:source].to_s + '.' + self.table_name
    
    
    @source_table = options[:source_table]
    @source_columns = _filter_columns.map { |column_name|
      _mappings.key?(column_name) ? _mappings[column_name] : column_name
    }
    
    @adapter = TheSync::Adapter.adapter(options[:source])
    
    @source_pk = 'id'
    
    extend TheSync::Table
  end
  
  
  def migrate_sync
  
  end
  
  def create_temp_table
    sql = "CREATE TEMPORARY TABLE #{@view_name} ("
    sql << sql_table(only: @source_columns)
    sql << ")"
    sql << "ENGINE=FEDERATED"
    sql << "CONNECTION='#{@server_name}/#{@source_table}'"
    
    connection.exec(sql)
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