class AddHelperDisabledUserSetting < ActiveRecord::Migration
  def change
    add_column :user_settings, :helper_disabled, :boolean, default: false, null: false
  end
end
