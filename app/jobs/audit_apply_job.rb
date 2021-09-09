module Sync
  class AuditApplyJob < ApplicationJob
    queue_as :default

    def perform(synchro_type, operation: ['update', 'insert', 'delete'])
      Audit.apply_synchro(synchro_type, operation: operation)
      Audit.apply_callback(synchro_type, operation: operation)
    end

  end
end
