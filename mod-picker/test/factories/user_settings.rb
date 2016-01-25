FactoryGirl.define do
  factory :user_setting do
    id 1
user_id 1
show_notifications false
show_tooltips false
email_notifications false
email_public false
allow_adult_content false
allow_nexus_mods false
allow_lovers_lab false
allow_steam_workshop false
timezone "MyText"
udate_format "MyText"
utime_format "MyText"
  end

end
