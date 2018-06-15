class AddModListAuthors < ActiveRecord::Migration
  def change
    create_table :mod_list_authors do |t|
      t.integer :mod_list_id, null: false
      t.integer :user_id, null: false
      t.integer :role, limit: 1, default: 0, null: false
    end

    add_foreign_key :mod_list_authors, :mod_lists
    add_foreign_key :mod_list_authors, :users
  end
end
