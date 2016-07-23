class AddModListGroups < ActiveRecord::Migration
  def change
    create_table "mod_list_groups" do |t|
      t.integer :mod_list_id, null: false
      t.integer :tab, limit: 1, default: 0, null: false #enum tab: [:tools, :mods, :plugins]
      t.integer :color, limit: 1, default: 0, null: false
      t.string :name, limit: 128, null: false
      t.text :description
    end

    # create foreign keys for mod list groups table
    add_foreign_key :mod_list_groups, :mod_lists

    # add columns to mod list mods, plugins, and custom plugins to reference mod list groups
    add_column :mod_list_mods, :group_id, :integer, after: :mod_list_id
    add_column :mod_list_plugins, :group_id, :integer, after: :mod_list_id
    add_column :mod_list_custom_plugins, :group_id, :integer, after: :mod_list_id

    # add foreign keys for reference columns
    add_foreign_key :mod_list_mods, :mod_list_groups, column: :group_id
    add_foreign_key :mod_list_plugins, :mod_list_groups, column: :group_id
    add_foreign_key :mod_list_custom_plugins, :mod_list_groups, column: :group_id
  end
end
