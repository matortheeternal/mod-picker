class AddModIdToConfigFiles < ActiveRecord::Migration
  def change
    add_column :config_files, :mod_id, :integer, null: false, after: :game_id
    add_foreign_key :config_files, :mods
  end
end
