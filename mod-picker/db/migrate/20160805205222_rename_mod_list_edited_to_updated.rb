class RenameModListEditedToUpdated < ActiveRecord::Migration
  def change
    rename_column :mod_lists, :edited, :updated
  end
end
