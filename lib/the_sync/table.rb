module TheSync
  module Table

    def dest_columns
      @adapter.columns(@dest_table)
    end

    def sql_table(table, only: [], except: [])

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
