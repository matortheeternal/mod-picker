class AddConflictMap < ActiveRecord::Migration
  def change
    create_table :worldspaces do |t|
      t.integer :game_id
      t.integer :plugin_id
      t.integer :fid
      t.string :name
    end

    add_foreign_key :worldspaces, :games
    add_foreign_key :worldspaces, :plugins

    create_table :cells do |t|
      t.integer :game_id
      t.integer :worldspace_id
      t.integer :x, default: 0, limit: 1
      t.integer :y, default: 0, limit: 1
      t.integer :fid
    end

    add_foreign_key :cells, :games
    add_foreign_key :cells, :worldspaces
    add_index :cells, :fid
  end
end
