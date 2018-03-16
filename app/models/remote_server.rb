class RemoteServer < ApplicationRecord
  self.establish_connection connection_config.merge(database: 'mysql')
  self.table_name = 'servers'

end
