class AddModListCustomMods < ActiveRecord::Migration
  def change
    create_table "mod_list_custom_mods" do |t|
      t.integer :mod_list_id, null: false
      t.integer :group_id, null: false
      t.integer :index, limit: 2, null: false
      t.string :name, limit: 255, null: false
      t.text :description
    end

    add_foreign_key :mod_list_custom_mods, :mod_lists
    add_foreign_key :mod_list_custom_mods, :mod_list_groups, column: :group_id
  end
end
