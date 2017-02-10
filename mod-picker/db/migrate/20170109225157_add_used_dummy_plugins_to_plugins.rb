class AddUsedDummyPluginsToPlugins < ActiveRecord::Migration
  def change
    add_column :plugins, :used_dummy_plugins, :boolean, default: false, null: false
  end
end
