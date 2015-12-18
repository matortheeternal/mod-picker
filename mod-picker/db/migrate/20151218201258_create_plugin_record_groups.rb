class CreatePluginRecordGroups < ActiveRecord::Migration
  def change
    create_table :plugin_record_groups do |t|
      t.integer :pl_id
      t.string :sig
      t.text :name
      t.integer :new_records
      t.integer :override_records

      t.timestamps null: false
    end
  end
end
