class CreateActiveModLists < ActiveRecord::Migration
  def change
    create_table :active_mod_lists do |t|
      t.integer :game_id, null: false
      t.integer :user_id, null: false
      t.integer :mod_list_id, null: false
    end

    add_foreign_key :active_mod_lists, :games
    add_foreign_key :active_mod_lists, :users
    add_foreign_key :active_mod_lists, :mod_lists
    add_index :active_mod_lists, [:game_id, :user_id, :mod_list_id], unique: true

    User.find_each do |user|
      next unless user.active_mod_list_id
      puts "User #{user.id}, active mod list: #{user.active_mod_list_id}"
      ActiveModList.create({
          game_id: user.active_mod_list.game_id,
          user_id: user.id,
          mod_list_id: user.active_mod_list_id
      })
    end

    remove_foreign_key :users, column: "active_mod_list_id"
    remove_column :users, :active_mod_list_id
  end
end
