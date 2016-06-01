class AdjustPluginErrorsFieldLengths < ActiveRecord::Migration
  def change
    change_column :plugin_errors, :path, :string, limit: 400
    change_column :plugin_errors, :name, :string, limit: 400
    change_column :plugin_errors, :data, :string, limit: 255
  end
end
