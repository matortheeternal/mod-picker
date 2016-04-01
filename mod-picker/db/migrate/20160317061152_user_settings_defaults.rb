class UserSettingsDefaults < ActiveRecord::Migration
  def change
    change_column :user_settings, :show_notifications, :boolean, :default => true
    change_column :user_settings, :show_tooltips, :boolean, :default => true
    change_column :user_settings, :email_notifications, :boolean, :default => false
    change_column :user_settings, :email_public, :boolean, :default => false
    change_column :user_settings, :allow_adult_content, :boolean, :default => false
    change_column :user_settings, :allow_nexus_mods, :boolean, :default => true
    change_column :user_settings, :allow_lovers_lab, :boolean, :default => false
    change_column :user_settings, :allow_steam_workshop, :boolean, :default => true
  end
end
