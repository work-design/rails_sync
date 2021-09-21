module Mysql
  class Table < ApplicationRecord
    self.establish_connection connection_config.merge(database: 'information_schema')
    self.table_name = 'ENGINES'

  end
end
