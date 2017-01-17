class AddGameSpecificThemes < ActiveRecord::Migration
  def change
    rename_column :user_settings, :theme, :skyrim_theme
    add_column :user_settings, :skyrimse_theme, :string, limit: 64, after: :skyrim_theme
    add_column :user_settings, :fallout4_theme, :string, limit: 64, after: :skyrimse_theme
    add_column :user_settings, :oblivion_theme, :string, limit: 64, after: :fallout4_theme
    add_column :user_settings, :falloutnv_theme, :string, limit: 64, after: :oblivion_theme
    add_column :user_settings, :fallout3_theme, :string, limit: 64, after: :falloutnv_theme
  end
end
