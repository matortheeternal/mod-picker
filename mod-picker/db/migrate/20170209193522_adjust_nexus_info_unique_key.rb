class AdjustNexusInfoUniqueKey < ActiveRecord::Migration
  def change
    rename_column :nexus_infos, :id, :nexus_id
    add_index :nexus_infos, ["nexus_id", "game_id"], :unique => true
    connection.execute "ALTER TABLE nexus_infos DROP PRIMARY KEY, ADD PRIMARY KEY(nexus_id, game_id);"
  end
end
