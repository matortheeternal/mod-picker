class UserBio < ActiveRecord::Base
  after_initialize :init

  belongs_to :user
  
  def init
    self.nexus_verified = false
    self.lover_verified = false
    self.steam_verified = false
  end
end
