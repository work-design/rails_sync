require 'mysql2'

module TheSync::Adapter
  class Mysql < Base

    def initialize(options = {})
      options.merge(database_timezone: :local, application_timezone: :local)
      @client = Mysql2::Client.new(options)
      @connection = "mysql://#{options[:username]}:#{options[:password]}@#{options[:host]}:#{options[:port]}/#{options[:database]}"
      @database = options[:database]
    end

    def tables
      _table = Arel::Table.new 'information_schema.TABLES'
      query = _table.project(_table['table_name'])
      query = query.where(_table['TABLE_SCHEMA'].eq(database).and(_table['TABLE_TYPE'].eq('BASE TABLE')))
      query = query.order(_table['table_name'])

      execute(query.to_sql).map { |table| "`#{table['table_name']}`" }
    end

    def columns(table_path)
      _table = Arel::Table.new 'information_schema.COLUMNS'
      query = _table.project(_table['COLUMN_NAME'],
                             _table['COLUMN_TYPE'],
                             _table['IS_NULLABLE'],
                             _table['COLUMN_DEFAULT'],
                             _table['EXTRA'],
                             _table['COLLATION_NAME'])
      query =query.where(_table['TABLE_SCHEMA'].eq(database).and(_table['TABLE_NAME'].eq(table_path)))

      execute(query.to_sql)
    end

    def primary_key(table_path)
      _table = Arel::Table.new 'information_schema.COLUMNS'
      query = _table.project(_table['COLUMN_NAME'])
      query = query.where(_table['TABLE_SCHEMA'].eq(database).and(_table['TABLE_NAME'].eq(table_path)).and(_table['COLUMN_KEY'].eq('PRI')))

      execute(query.to_sql)
    end

    def indexes(table_path)
      _table = Arel::Table.new 'information_schema.STATISTICS'
      query = _table.project(_table['INDEX_NAME'],
                             _table['COLUMN_NAME'])
      query =query.where(_table['TABLE_SCHEMA'].eq(database).and(_table['TABLE_NAME'].eq(table_path)).and(_table['INDEX_NAME'].not_eq('PRIMARY')))

      execute(query.to_sql)
    end

  end
end
