class ReadNotification < ActiveRecord::Base
  self.primary_keys = :event_id, :user_id

  # ASSOCIATIONS
  belongs_to :event, :inverse_of => 'read_notifications'
  belongs_to :user, :inverse_of => 'read_notifications'

  # VALIDATIONS
  validates :event_id, :user_id, presence: true
end