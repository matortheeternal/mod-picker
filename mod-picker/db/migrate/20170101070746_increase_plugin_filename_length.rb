class IncreasePluginFilenameLength < ActiveRecord::Migration
  def change
    change_column :plugins, :filename, :string, limit: 256, null: false
  end
end
