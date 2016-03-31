class UpdateModListPluginsTable < ActiveRecord::Migration
  def change
    change_column :mod_list_plugins, :load_order, :integer
    rename_column :mod_list_plugins, :load_order, :index
  end
end
