class Notification < ActiveRecord::Base
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

  def as_json(options={})
    if JsonHelpers.json_options_empty(options)
      default_options = {
          :only => [],
          :include => {
              :event => {
                  :include => {
                      :content => event.content_json
                  }
              }
          }
      }
      super(options.merge(default_options))
    else
      super(options)
    end
  end
end