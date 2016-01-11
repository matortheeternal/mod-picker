class UserReputation < ActiveRecord::Base
  belongs_to :User
  after_initialize :init
  
  def init
    self.overall = 5.0
    self.offset = 0.0
    self.audiovisual_design = 0.0
    self.plugin_design = 0.0
    self.utilty_design = 0.0
    self.script_design = 0.0
  end
end
