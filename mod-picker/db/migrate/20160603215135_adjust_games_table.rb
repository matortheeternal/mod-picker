class AdjustGamesTable < ActiveRecord::Migration
  def change
    change_table "games" do |t|
      t.column :parent_game_id, :integer, null: true, after: :id
      t.change :nexus_name, :string, limit: 16, null: true, after: :abbr_name
      t.change :exe_name, :string, limit: 32, null: true
      t.change :steam_app_ids, :string, limit: 64, null: true
    end

    add_foreign_key :games, :games, column: :parent_game_id
  end
end
