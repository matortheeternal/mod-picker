class Notification < ActiveRecord::Base
  include BetterJson

  # ATTRIBUTES
  self.primary_keys = :event_id, :user_id
  self.per_page = 50

  # SCOPES
  scope :unread, -> { where(read: false) }
  scope :events, -> (ids) { where(event_id: ids) }
  scope :user, -> (id) { where(user_id: id) }
  scope :mark_read, -> { update_all(read: true) }

  # ASSOCIATIONS
  belongs_to :event, :inverse_of => 'notifications'
  belongs_to :user, :inverse_of => 'notifications'

  # VALIDATIONS
  validates :event_id, :user_id, presence: true
end