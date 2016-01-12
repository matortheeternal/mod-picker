class UserBio < ActiveRecord::Base
  after_initialize :init
  
  def init
    self.nexus_verified = false
    self.lover_verified = false
    self.steam_verified = false
  end
end
