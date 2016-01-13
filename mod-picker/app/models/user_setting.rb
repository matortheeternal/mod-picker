class UserSetting < ActiveRecord::Base
  after_initialize :init
  
  def init
    self.show_notifications = true
    self.show_tooltips = true
    self.email_notifications = false
    self.email_public = false
    self.allow_adult_content = false
    self.allow_nexus_mods = true
    self.allow_lovers_lab = false
    self.allow_steam_workshop = true
    self.timezone = "Pacific Time (US & Canada)"
    self.udate_format = "%F"
    self.utime_format = "%I:%M%p"
  end
end
