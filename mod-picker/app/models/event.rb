class Event < ActiveRecord::Base
  include ScopeHelpers, BetterJson, Dateable, Dateable

  # ATTRIBUTES
  enum event_type: [:added, :updated, :removed, :hidden, :unhidden, :approved, :unapproved, :status, :action_soon, :message, :unused, :milestone1, :milestone2, :milestone3, :milestone4, :milestone5, :milestone6, :milestone7, :milestone8, :milestone9, :milestone10]
  self.per_page = 100

  # DATE COLUMNS
  date_column :created

  # SCOPES
  enum_scope :event_type
  polymorphic_scope :content

  # ASSOCIATIONS
  belongs_to :content, :polymorphic => true
  has_many :notifications, :inverse_of => 'event', :dependent => :destroy

  # VALIDATIONS
  validates :content_id, :content_type, :event_type, presence: true
  validates :content_type, length: {in: 1..32}

  # CALLBACKS
  after_create :create_notifications

  def self.milestones
    [:milestone1, :milestone2, :milestone3, :milestone4, :milestone5, :milestone6, :milestone7, :milestone8, :milestone9, :milestone10]
  end

  # Private methods
  private
    def create_notifications
      content.notify_subscribers(self)
    end
end