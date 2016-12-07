class AddDescriptionToModListModsAndPlugins < ActiveRecord::Migration
  def change
    add_column :mod_list_mods, :description, :text
    add_column :mod_list_plugins, :description, :text
  end
end
