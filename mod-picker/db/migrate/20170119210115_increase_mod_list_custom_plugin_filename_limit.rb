class IncreaseModListCustomPluginFilenameLimit < ActiveRecord::Migration
  def change
    change_column :mod_list_custom_plugins, :filename, :string, limit: 255, null: false
  end
end
