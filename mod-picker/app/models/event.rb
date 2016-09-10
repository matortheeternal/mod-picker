class Event < ActiveRecord::Base
  include ScopeHelpers

  # We could save bandwidth by doing this on the frontend, if we wanted to
  enum event_type: [:added, :updated, :removed, :hidden, :unhidden, :approved, :unapproved, :status_changed, :action_soon, :message, :unused, :milestone1, :milestone2, :milestone3, :milestone4, :milestone5, :milestone6, :milestone7, :milestone8, :milestone9, :milestone10]

  # SCOPES
  enum_scope :event_type
  polymorphic_scope :content

  # ASSOCIATIONS
  belongs_to :content, :polymorphic => true
  has_many :notifications, :inverse_of => 'event'

  # number of events per page on the notifications index
  self.per_page = 50

  # VALIDATIONS
  validates :content_id, :content_type, :event_type, presence: true
  validates :content_type, length: {in: 1..32}

  # CALLBACKS
  before_create :set_dates

  def as_json(options={})
    if JsonHelpers.json_options_empty(options)
      default_options = {
          :include => {
              :content => content.notification_json_options
          }
      }
      super(options.merge(default_options))
    else
      super(options)
    end
  end

  # Private methods
  private
    def set_dates
      self.created = DateTime.now
    end
end