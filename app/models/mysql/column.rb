module Mysql
  class Column < ApplicationRecord
    self.establish_connection connection_config.merge(database: 'information_schema')
    self.table_name = 'COLUMNS'

  end
end
