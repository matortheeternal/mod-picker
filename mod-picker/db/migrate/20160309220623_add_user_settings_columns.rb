class AddUserSettingsColumns < ActiveRecord::Migration
  def change
    add_column :user_settings, :allow_comments, :boolean
    add_column :user_settings, :theme, :string
  end
end