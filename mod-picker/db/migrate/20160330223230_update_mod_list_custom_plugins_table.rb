class UpdateModListCustomPluginsTable < ActiveRecord::Migration
  def change
    change_column :mod_list_custom_plugins, :load_order, :integer, limit: 2
    rename_column :mod_list_custom_plugins, :load_order, :index
    rename_column :mod_list_custom_plugins, :title, :filename
  end
end
