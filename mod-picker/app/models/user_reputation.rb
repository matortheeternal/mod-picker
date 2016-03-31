class UserReputation < ActiveRecord::Base
  include Filterable

  before_validation :init

  belongs_to :user

  scope :user, -> (id) { where(user_id: id) }
  
  def init
    self.overall ||= 5.0
    self.offset ||= 5.0
    self.site_rep ||= 0.0
    self.contribution_rep ||= 0.0
    self.author_rep ||= 0.0
    self.given_rep ||= 0.0
    self.dont_compute ||= false
    self.last_computed ||= DateTime.now
  end
end
