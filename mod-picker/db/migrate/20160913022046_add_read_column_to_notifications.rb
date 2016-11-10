class AddReadColumnToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :read, :boolean, default: false, null: false
  end
end
