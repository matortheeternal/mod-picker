class AddGameAssociations < ActiveRecord::Migration
  def change
    add_column :articles, :game_id, :integer
    add_column :asset_files, :game_id, :integer, null: false
    add_column :compatibility_notes, :game_id, :integer, null: false
    add_column :corrections, :game_id, :integer, null: false
    add_column :install_order_notes, :game_id, :integer, null: false
    add_column :load_order_notes, :game_id, :integer, null: false
    add_column :reviews, :game_id, :integer, null: false
    add_column :plugins, :game_id, :integer, null: false

    add_foreign_key :asset_files, :games
    add_foreign_key :compatibility_notes, :games
    add_foreign_key :corrections, :games
    add_foreign_key :install_order_notes, :games
    add_foreign_key :load_order_notes, :games
    add_foreign_key :reviews, :games
    add_foreign_key :plugins, :games
  end
end
