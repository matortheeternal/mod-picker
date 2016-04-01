class RenameUserLevelToRole < ActiveRecord::Migration
  def change
    rename_column :users, :user_level, :role
    change_column :users, :role, :string, limit: 16
  end
end
