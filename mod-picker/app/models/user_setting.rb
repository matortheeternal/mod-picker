class UserSetting < ActiveRecord::Base
  include Filterable, BetterJson

  belongs_to :user

  # VALIDATIONS
  validates :user_id, presence: true
  validates :theme, length: {maximum: 64}
  validates :allow_comments, :show_notifications, :email_notifications, :email_public, :allow_adult_content, :allow_nexus_mods, :allow_lovers_lab, :allow_steam_workshop, inclusion: [true, false]

  # CALLBACKS
  before_create :init

  def init
    self.theme ||= "Whiterun"
  end
end
