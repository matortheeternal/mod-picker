class UserSetting < ActiveRecord::Base
  belongs_to :User
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
  end
end
