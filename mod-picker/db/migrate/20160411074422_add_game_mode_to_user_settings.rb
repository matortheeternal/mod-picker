class AddGameModeToUserSettings < ActiveRecord::Migration
  def change
    add_column :user_settings, :game_mode, :integer
    add_foreign_key :user_settings, :games, :column => :game_mode
  end
end
