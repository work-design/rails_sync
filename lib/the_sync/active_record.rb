module TheSync::ActiveRecord
  
  
  def acts_as_sync(options = {})
  
    
    
    # 'source.table_name'
    @view_name = options[:source] + '.' + self.table_name
    @source_table = options[:source_table]
   end
  
  
  def migrate_sync
  
  end
  
  def create_view
    "CREATE VIEW #{@view_name} AS"
  
  end
  
  def source_select
    query = table.project columns.map { |column| table[column] }
    query = query.where table[primary_key].in(ids)
  
    execute(query.to_sql).each
  end
  
  def view_name
    
    "#{source}"
  end
  
  
end



ActiveSupport.on_load :active_record do
  extend TheSync::ActiveRecord
end