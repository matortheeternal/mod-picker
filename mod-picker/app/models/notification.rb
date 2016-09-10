class Notification < ActiveRecord::Base
  self.primary_keys = :event_id, :user_id

  # ASSOCIATIONS
  belongs_to :event, :inverse_of => 'notifications'
  belongs_to :user, :inverse_of => 'notifications'

  # VALIDATIONS
  validates :event_id, :user_id, presence: true
end