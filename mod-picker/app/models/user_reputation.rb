class UserReputation < ActiveRecord::Base
  include Filterable

  after_initialize :init

  belongs_to :user

  scope :user, -> (id) { where(user_id: id) }
  
  def init
    self.overall ||= 5.0
    self.offset ||= 0
    self.audiovisual_design ||= 0
    self.plugin_design ||= 0
    self.utility_design ||= 0
    self.script_design ||= 0
  end
end
