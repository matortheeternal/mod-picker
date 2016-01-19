class AddGamesTable < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.text    :short_name, :long_name, :abbr_name, :exe_name, :steam_app_ids, limit: 255
    end
    
    change_table :mods do |t|
      t.remove :game
      t.column :game_id, :integer
    end
    
    reversible do |dir|
      dir.up do
        execute("ALTER TABLE games MODIFY id INT UNSIGNED NOT NULL AUTO_INCREMENT;")
        execute("ALTER TABLE mods MODIFY game_id INT UNSIGNED;")
      end
    end
    
    # add foreign key
    add_foreign_key :mods, :games
  end
end
