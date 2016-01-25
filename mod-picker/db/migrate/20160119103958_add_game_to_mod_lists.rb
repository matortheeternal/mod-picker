class AddGameToModLists < ActiveRecord::Migration
  def change
    add_column :mod_lists, :game_id, :integer
    
    execute("ALTER TABLE mod_lists MODIFY game_id INT UNSIGNED NOT NULL;")
    
    add_foreign_key :mod_lists, :games
  end
end
