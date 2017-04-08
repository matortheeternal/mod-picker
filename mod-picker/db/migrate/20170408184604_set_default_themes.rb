class SetDefaultThemes < ActiveRecord::Migration
  def change
    UserSetting.where(skyrim_theme: nil).update_all("skyrim_theme = 'High Hrothgar'")
    UserSetting.where(skyrimse_theme: nil).update_all("skyrimse_theme = 'Falkreath'")
    UserSetting.where(fallout4_theme: nil).update_all("fallout4_theme = 'Workshop'")
  end
end
