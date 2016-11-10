class RenameErrorsTypeColumn < ActiveRecord::Migration
  def change
    rename_column :plugin_errors, :type, :group
  end
end
