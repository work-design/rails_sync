module TheSync
  module Table

    def dest_columns
      @adapter.columns(@dest_table)
    end

    def dest_indexes
      @adapter.indexes(@dest_table)
    end

    def dest_primary_key
      results = @adapter.primary_key(@dest_table)
      Hash(results[0])['COLUMN_NAME']
    end

    def dest_sql_table(only: [], except: [], pure: true)
      if only.size > 0
        _columns = dest_columns.select { |column| only.include?(column['COLUMN_NAME']) }
      else
        _columns = dest_columns.reject { |column| except.include?(column['COLUMN_NAME']) }
      end

      if pure
        sql = ""
      else
        sql = "CREATE TABLE `#{@dest_table}` (\n"
      end

      _columns.each do |column|
        sql << "  `#{column['COLUMN_NAME']}` #{column['COLUMN_TYPE']}"
        sql << " COLLATE #{column['COLLATION_NAME']}" if column['COLLATION_NAME'].present?
        sql << " NOT NULL" if column['IS_NULLABLE'] == 'NO'
        if column['COLUMN_DEFAULT']
          sql << " DEFAULT '#{column['COLUMN_DEFAULT']}',\n"
        elsif column['COLUMN_DEFAULT'].nil? && column['IS_NULLABLE'] == 'YES'
          sql << " DEFAULT NULL,\n"
        else
          sql << ",\n"
        end
      end

      sql << "  PRIMARY KEY (`#{dest_primary_key}`)"

      _indexes = dest_indexes.reject { |index| index['INDEX_NAME'] == 'PRIMARY' }
      _indexes = dest_indexes.reject { |index| (Array(index['COLUMN_NAME']) & _columns.map { |col| col['COLUMN_NAME'] }).blank? }

      if _indexes.present?
        sql << ",\n"
      else
        sql << "\n"
      end
      _indexes.each_with_index do |index, position|
        sql << "  KEY `#{index['INDEX_NAME']}` ("
        sql << "`#{index['COLUMN_NAME']}`"

        if position + 1 == _indexes.size
          sql << ")\n"
        else
          sql << "),\n"
        end
      end

      if pure
        sql
      else
        sql << ")"
      end
    end

    def checksum
      (@from.checksum == @to.checksum)
    end

    def valid_schema
      @from.primary_key && @to.primary_key
    end

    def get_dump_head
      @to.dump_head
    end

    def get_dump_bottom
      @to.dump_bottom
    end

    def equal_table
      (@from.desc_table == @to.desc_table)
    end

    def do_alter_table_modify
      left   = @from.get_desc_table
      right  = @to.get_desc_table
      diff   = left - right

      diff.map { |alter|
        @to.alter_table(alter, right, left)
      }
    end

    def do_alter_table_remove
      left   = @from.get_desc_table
      right  = @to.get_desc_table
      remove = right.map{|k,v| k } - left.map{|k,v| k }

      remove.map { |column|
        @to.drop_column(column)
      }
    end

    def migrate_items
      insert_items.each { |row| puts row }
      update_items.each { |row| puts row }
      delete_items.each { |row| puts row }
    end

    def insert_items
      ids = @from.ids - @to.ids
      items = @from.data(ids)

      @to.insert(items)
    end

    def update_items
      left  = (@from.md5s - @to.md5s).map{ |k, _| k }
      right = (@to.md5s   - @from.md5s).map{ |k, _| k }
      diff  = left & right

      items = @from.data(diff)

      @to.update(items)
    end

    def delete_items
      ids = @to.ids - @from.ids

      @to.delete ids
    end

  end
end
