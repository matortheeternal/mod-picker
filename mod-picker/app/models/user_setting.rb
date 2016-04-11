class UserSetting < ActiveRecord::Base
  include Filterable

  before_create :init

  belongs_to :user

  scope :user, -> (id) { where(user_id: id) }

  def init
    self.timezone ||= "Pacific Time (US & Canada)"
    self.udate_format ||= "%F"
    self.utime_format ||= "%I:%M%p"
    self.theme ||= "Whiterun"
    self.game_mode ||= Game.find_by(:display_name => 'Skyrim').id
  end
end
