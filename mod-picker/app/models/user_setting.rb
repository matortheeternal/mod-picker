class UserSetting < ActiveRecord::Base
  include Filterable, BetterJson

  belongs_to :user

  # VALIDATIONS
  validates :user_id, presence: true
  validates :skyrim_theme, :skyrimse_theme, :fallout4_theme, :fallout3_theme, :falloutnv_theme, :oblivion_theme, length: {maximum: 64}
  validates :allow_comments, :show_notifications, :email_notifications, :email_public, :allow_adult_content, :allow_nexus_mods, :allow_lovers_lab, :allow_steam_workshop, inclusion: [true, false]

  # SET DEFAULT THEMES
  before_create :set_default_themes

  private
    def set_default_themes
      self.skyrim_theme = 'High Hrothgar'
      self.skyrimse_theme = 'Falkreath'
      self.fallout4_theme = 'Workshop'
    end
end
