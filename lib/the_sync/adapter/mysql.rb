require 'mysql2'

module TheSync::Adapter
  class Mysql < Base
      
    def initialize(options = {})
      options.merge(database_timezone: :local, application_timezone: :local)
      @client = Mysql2::Client.new(options)
    end
  
    def primary_key
      _table = Arel::Table.new 'information_schema.COLUMNS'
      query = _table.project(_table['COLUMN_NAME'])
      query = query.where(_table['TABLE_SCHEMA'].eq(database))
      query = query.and(_table['TABLE_NAME'].eq(table))
      query = query.and(_table['COLUMN_KEY'].eq('PRI'))
      
      execute(query.to_sql).each(:as => :array).join(',')
    end
  
    def ids
      sql = "SELECT MD5(CONCAT(#{primary_key})) AS id FROM #{table_path};"
      execute(sql).each(:as => :array)
    end
  
    def md5s
      md5 = columns.map { |column| "COALESCE(#{column}, '#{column}')"}
      sql     = "SELECT MD5(CONCAT(#{primary_key})) AS id, MD5(CONCAT(#{md5.join(', ')})) AS md5 FROM #{table_path};"
  
      execute(sql).each(:as => :array)
    end
    
    def checksum_table
      "CHECKSUM TABLE #{table_path}"
    end
  
    def checksum
      md5 = columns.map { |column| "COALESCE(#{column}, '#{column}')"}.join(', ')
      query = table.project Arel.sql("SUM(CRC32(CONCAT(#{md5}))) AS sum")
  
      execute(query.to_sql).each(:as => :array).first.first.to_i
    end
  
    def drop_column(name)
      sql  = 'ALTER TABLE '
      sql << table_path
      sql << ' DROP COLUMN '
      sql << name
      sql << ';'
    end
  
    def value(value, key = nil)
      if value.kind_of?(Array)
        value(value.first, key)
      else
        if value.nil?
          'NULL'
        elsif value == 'CURRENT_TIMESTAMP'
          value
        elsif key.nil?
          if !is_a_number?(value)
            "'#{value}'"
          else
            value
          end
        else
          case get_datatype(key)
            when 'INT', 'TINYINT', 'SMALLINT', 'MEDIUMINT', 'BIGINT', 'FLOAT', 'DOUBLE', 'DECIMAL'
              value
            when 'DATE', 'DATETIME', 'TIMESTAMP', 'TIME', 'YEAR'
              "'#{value}'"
            when 'CHAR', 'VARCHAR', 'BLOB', 'TEXT', 'TINYBLOB', 'TINYTEXT', 'MEDIUMBLOB', 'MEDIUMTEXT', 'LONGBLOB', 'LONGTEXT', 'ENUM'
              value(@mysql.escape(value))
            else
              value(value)
          end
        end
      end
    end
    
    def tables
      _table = Arel::Table.new 'information_schema.TABLES'
      query = _table.project(_table['table_name'])
      query = query.where(_table['TABLE_SCHEMA'].eq(database))
      query = query.and(_table['TABLE_TYPE'].eq('BASE TABLE'))
      query = query.order(_table['table_name'])
  
      execute(query.to_sql).map { |table| "`#{table['table_name']}`" }
    end
  
    def desc_table
      _table = Arel::Table.new 'information_schema.COLUMNS'
      query = _table.project(_table['COLUMN_NAME'],
                             _table['COLUMN_TYPE'],
                             _table['IS_NULLABLE'],
                             _table['COLUMN_DEFAULT'],
                             _table['EXTRA'],
                             _table['ORDINAL_POSITION'])
  
      query = query.where(_table['TABLE_SCHEMA'].eq(database))
      query = query.and(_table['TABLE_NAME'].eq(table_path))
      
      
      execute(query.to_sql).each(as: :array)
    end
  
    def columns
      _table = Arel::Table.new 'information_schema.COLUMNS'
      query = _table.project(_table['COLUMN_NAME'])
      query =query.where(_table['TABLE_SCHEMA'].eq(database))
      query = query.and(_table['TABLE_NAME'].eq(table_path))
  
      execute(query.to_sql).map { |column| "`#{column['COLUMN_NAME']}`" }
    end
  
    def alter_table(alter, right, left)
      column  = alter[0]
      type    = alter[1]
      default = value(alter[3], alter[0])
      action  = (right.any? {|i| i.first == alter.first})? ' MODIFY' : ' ADD'
      notnull = (alter[2] == 'NO')? ' NOT NULL' : ' NULL'
      default = (!alter[3].nil?)? " DEFAULT #{default}" : ''
      extra   = (!alter[4].empty?)? " #{alter[4]}" : ''
      index   = left.each_index.select{|i| left[i] == alter}.first
      after   = left[((index > 0)? index - 1 : 0)].first
      after   = (index > 0)? " AFTER #{after}" : ' FIRST'
  
      sql = "ALTER TABLE #{table_path} #{action} COLUMN #{column} #{type} #{notnull} #{default} #{extra} #{after};"
      sql
    end
    
    
  end
end
