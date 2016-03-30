class UpdateModListModsTable < ActiveRecord::Migration
  def change
    change_column :mod_list_mods, :install_order, :integer
    rename_column :mod_list_mods, :install_order, :index
  end
end
