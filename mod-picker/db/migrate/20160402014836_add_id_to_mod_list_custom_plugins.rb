class AddIdToModListCustomPlugins < ActiveRecord::Migration
  def change
    add_column :mod_list_custom_plugins, :id, :primary_key
  end
end
