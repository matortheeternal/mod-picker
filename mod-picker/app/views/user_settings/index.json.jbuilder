json.array!(@user_settings) do |user_setting|
  json.extract! user_setting, :id, :user_id, :show_notifications, :show_tooltips, :email_notifications, :email_public, :allow_adult_content, :allow_nexus_mods, :allow_lovers_lab, :allow_steam_workshop, :timezone, :udate_format, :utime_format
  json.url user_setting_url(user_setting, format: :json)
end
