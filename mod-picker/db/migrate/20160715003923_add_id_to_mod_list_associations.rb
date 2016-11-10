class AddIdToModListAssociations < ActiveRecord::Migration
  def change
    add_column :mod_list_mods, :id, :primary_key
    add_column :mod_list_plugins, :id, :primary_key
    add_column :mod_list_compatibility_notes, :id, :primary_key
    add_column :mod_list_install_order_notes, :id, :primary_key
    add_column :mod_list_load_order_notes, :id, :primary_key
    add_column :mod_list_config_files, :id, :primary_key
  end
end
