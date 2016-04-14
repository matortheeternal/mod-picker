class RemoveGameModeFromUsers < ActiveRecord::Migration
  def change
    remove_foreign_key :user_settings, :column => :game_mode
    remove_column :user_settings, :game_mode
  end
end
