class Notification < ActiveRecord::Base
  self.primary_keys = :event_id, :user_id

  # SCOPES
  scope :unread, -> { where(read: false) }

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