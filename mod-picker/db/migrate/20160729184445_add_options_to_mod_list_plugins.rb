class AddOptionsToModListPlugins < ActiveRecord::Migration
  def change
    remove_column :mod_list_plugins, :active
    remove_column :mod_list_mods, :active
    add_column :mod_list_plugins, :cleaned, :boolean, default: false, null: false
    add_column :mod_list_plugins, :merged, :boolean, default: false, null: false
  end
end
