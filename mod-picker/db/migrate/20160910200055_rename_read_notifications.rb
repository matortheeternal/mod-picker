class RenameReadNotifications < ActiveRecord::Migration
  def change
    rename_table :read_notifications, :notifications
  end
end
