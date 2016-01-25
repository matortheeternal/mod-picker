class CreateRecordGroupsTable < ActiveRecord::Migration
  def change
    remove_column :plugin_record_groups, :name
    
    create_table :record_groups do |t|
      t.integer :game_id
      t.string  :signature,   limit: 4
      t.string  :name,        limit: 64
      t.boolean :child_group
    end

    reversible do |dir|
      dir.up do
        # alter id to be unsigned
        execute("ALTER TABLE record_groups MODIFY id INT UNSIGNED NOT NULL AUTO_INCREMENT;")
        # alter game_id to be unsigned
        execute("ALTER TABLE record_groups MODIFY game_id INT UNSIGNED NULL;")
      end
    end

    add_foreign_key :record_groups, :games, column: :game_id
    add_index :record_groups, [:game_id, :signature], :unique => true
  end
end