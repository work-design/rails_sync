require 'arel'
module TheSync::Adapter
  class Base
    attr_reader :client
    attr_reader :connection
    
    def initialize(adapter, options = {})
      _options = TheSync.options[adapter]
      binding.pry
      adapter_class = self.class.lookup(_options[:adapter])
      @client = adapter_class.new(_options)
      
      #ObjectSpace.define_finalizer(self, self.class.method(:finalize))
    end
  
    def execute(sql)
      @client.query(sql).each
    end
  
    def finalize
      @mysql.close
    end
  
    def table_path
      "`#{@database}`.`#{@table}`"
    end
  
    def arel_table
      @arel_table ||= Arel::Table.new(table_path)
    end
  
  
    def is_a_number?(value)
      /^[+-]?\d+?(\.\d+)?$/ === value.to_s
    end
  
    def remove_timezone(timestamp)
      "SUBSTRING(#{timestamp}, 1, 19) AS #{timestamp}"
    end
  
    def get_datatype(column)
      get_desc_table.each do |c|
        if c.first == column
          return c[1].gsub(/\(\d+(\,\d+)?\)/, '').upcase
        end
      end
    end
  
    def data(ids = [])
      query = table.project columns.map { |column| table[column] }
      query = query.where table[primary_key].in(ids)
  
      execute(query.to_sql).each
    end
  
    def insert(items = [])
      return if items.size < 1
  
      im = Arel::InsertManager.new
      im.into table
      im.columns = items.first.keys.map { |key| table[key] }
      
      values = items.map { |item| item.values }
      im.values = im.create_values_list values
      im.to_sql
    end
  
    def update(items = [])
      items.map do |item|
        um = Arel::UpdateManager.new
        um.table table
    
        um.where table[primary_key].eq(item.delete(primary_key))
        _arr = items.map do |key, value|
          [table[key], value]
        end
        um.set _arr
    
        um.to_sql
      end
    end
  
    def delete(ids = [])
      dm = Arel::DeleteManager.new
      dm.from(arel_table)
      dm.where arel_table[primary_key].in(ids)
  
      dm.to_sql
    end
    
  end
end
