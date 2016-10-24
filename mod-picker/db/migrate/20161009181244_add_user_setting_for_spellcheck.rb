class AddUserSettingForSpellcheck < ActiveRecord::Migration
  def change
    add_column :user_settings, :enable_spellcheck, :boolean, default: true, null: false
  end
end
