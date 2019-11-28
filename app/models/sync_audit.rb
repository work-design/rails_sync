class SyncAudit < ApplicationRecord
  include RailsSync::SyncAudit
end unless defined? SyncAudit
