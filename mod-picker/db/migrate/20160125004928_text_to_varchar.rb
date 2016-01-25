class TextToVarchar < ActiveRecord::Migration
  def change
    change_column :categories, :name, :string, limit: 64
    change_column :games, :short_name, :string, limit: 32
    change_column :games, :long_name, :string, limit: 128
    change_column :games, :abbr_name, :string, limit: 32
    change_column :games, :exe_name, :string, limit: 32
    change_column :games, :steam_app_ids, :string, limit: 64
    change_column :mods, :name, :string, limit: 128
    change_column :mods, :aliases, :string, limit: 128
    change_column :nexus_infos, :uploaded_by, :string, limit: 128
    change_column :nexus_infos, :authors, :string, limit: 128
    change_column :plugins, :filename, :string, limit: 64
    change_column :plugins, :author, :string, limit: 128
    change_column :plugins, :description, :string, limit: 512
    change_column :user_settings, :timezone, :string, limit: 128
    change_column :user_settings, :udate_format, :string, limit: 128
    change_column :user_settings, :utime_format, :string, limit: 128
    change_column :users, :avatar, :string, limit: 128
  end
end