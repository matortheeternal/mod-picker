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
    self.show_notifications     ||= true
    self.show_tooltips          ||= true
    self.email_notifications    ||= false
    self.email_public           ||= false
    self.allow_adult_content    ||= false 
    self.allow_nexus_mods       ||= true
    self.allow_lovers_lab       ||= true
    self.allow_steam_workshop   ||= true
    # TODO: Set these values in user_settings
    # timezone: varchar(128)      ||= "PST"
    # udate_format: varchar(128)
    # Default to mm-dd-yyyy
    # utime_format: varchar(128)
    # Default to 12-hour format
  end
end
