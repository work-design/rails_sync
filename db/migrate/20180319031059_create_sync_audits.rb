class CreateSyncAudits < ActiveRecord::Migration[5.2]
  def change
    create_table :sync_audits do |t|
      t.references :operator, polymorphic: true
      t.references :synchro, polymorphic: true
      t.references :destined
      t.string :operation
      t.string :audited_changes, limit: 4096
      t.string :note, limit: 1024
      t.string :state
      t.datetime :apply_at
      t.timestamps
    end
  end
end
