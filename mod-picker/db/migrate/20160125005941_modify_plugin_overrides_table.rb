class ModifyPluginOverridesTable < ActiveRecord::Migration
  def change
    remove_column :plugin_overrides, :name
    rename_table :plugin_overrides, :override_records
  end
end
