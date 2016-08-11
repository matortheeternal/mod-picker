class UserSetting < ActiveRecord::Base
  include Filterable

  scope :user, -> (id) { where(user_id: id) }

  belongs_to :user

  # Validations
  validates :user_id, presence: true
  validates :theme, length: {maximum: 64}
  validates :allow_comments, :show_notifications, :email_notifications, :email_public, :allow_adult_content, :allow_nexus_mods, :allow_lovers_lab, :allow_steam_workshop, inclusion: [true, false]

  # Callbacks
  before_create :init

  def init
    self.theme ||= "Whiterun"
  end
end
