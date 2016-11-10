class FixUserSettingsDefaults < ActiveRecord::Migration
  def change
    change_column :user_settings, :email_notifications, :boolean, default: false, null: false
    change_column :user_settings, :email_public, :boolean, default: false, null: false
    change_column :user_settings, :allow_adult_content, :boolean, default: false, null: false

    UserSetting.update_all(email_notifications: false, email_public: false, allow_adult_content: false)
  end
end
