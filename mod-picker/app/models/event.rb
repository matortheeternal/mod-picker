class Event < ActiveRecord::Base
  include ScopeHelpers

  # ATTRIBUTES
  enum event_type: [:added, :updated, :removed, :hidden, :unhidden, :approved, :unapproved, :status, :action_soon, :message, :unused, :milestone1, :milestone2, :milestone3, :milestone4, :milestone5, :milestone6, :milestone7, :milestone8, :milestone9, :milestone10]
  self.per_page = 50

  # SCOPES
  enum_scope :event_type
  polymorphic_scope :content

  # ASSOCIATIONS
  belongs_to :content, :polymorphic => true
  has_many :notifications, :inverse_of => 'event'

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