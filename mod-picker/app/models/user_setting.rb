class UserSetting < ActiveRecord::Base
  include Filterable

  before_create :init

  belongs_to :user

  scope :user, -> (id) { where(user_id: id) }

  def init
    self.theme ||= "Whiterun"
  end
end
