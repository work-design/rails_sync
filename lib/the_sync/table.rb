module TheSync
  module Table
    attr_reader :dest_table_name

    def instance_table
      if same_server?
        # `source.table_name`
        @dest_table_name = @adapter.instance_variable_get(:@adapter_options)[:database].to_s + '.' + @dest_table.to_s
      else
        # `source_table_name`
        @dest_table_name = @dest.to_s + '_' + @table_name + '-' + @dest_table.to_s
      end
    end

    def same_server?
      @server_id == adapter.server_id
    end

    def dest_columns
      adapter.connection.columns(@dest_table)
    end

    def dest_indexes
      results = adapter.connection.indexes(@dest_table)
      results = results.map { |result| { result.name => result.columns } }
      results.to_combined_hash  # rails_com core ext
      results
    end

    def dest_primary_key
      adapter.connection.primary_key(@dest_table)
    end

    def dest_sql_table(only: [], except: [], pure: true)
      if only.size > 0
        _columns = dest_columns.select { |column| only.include?(column.name) }
      else
        _columns = dest_columns.reject { |column| except.include?(column.name) }
      end

      if pure
        sql = ""
      else
        sql = "CREATE TABLE `#{@dest_table}` (\n"
      end

      _columns.each do |column|
        sql << "  `#{column.name}` #{column.sql_type}"
        sql << " COLLATE #{column.collation}" if column.collation.present?
        sql << " NOT NULL" if column.null.is_a?(FalseClass)
        if column.default
          sql << " DEFAULT '#{column.default}',\n"
        elsif column.default.nil? && column.null
          sql << " DEFAULT NULL,\n"
        else
          sql << ",\n"
        end
      end

      sql << "  PRIMARY KEY (`#{dest_primary_key}`)"

      _indexes = dest_indexes.reject { |_, value| (Array(value) & _columns.map { |col| col.name }).blank? }

      if _indexes.present?
        sql << ",\n"
      else
        sql << "\n"
      end
      _indexes.each do |index, columns|
        sql << "  KEY `#{index}` ("
        sql << Array(columns).map { |col| "`#{col}`" }.join(',')
        sql << "),\n"
      end

      sql.chomp!(",\n")

      if pure
        sql
      else
        sql << ")"
      end
    end

    def reset_temp_table
      drop_temp_table
      create_temp_table
    end

    def create_temp_table
      unless @dest_columns.include?(dest_primary_key)
        @dest_columns.unshift dest_primary_key
      end

      sql = "CREATE TABLE `#{@dest_table_name}` (\n"
      sql << dest_sql_table(only: @dest_columns)
      sql << ")"
      sql << "ENGINE=FEDERATED\n"
      sql << "CONNECTION='#{adapter.url}/#{@dest_table}';"

      connection.execute(sql)
    end

    def drop_temp_table
      sql = "DROP TABLE IF EXISTS `#{@dest_table_name}`"

      connection.execute(sql)
    end

  end
end
