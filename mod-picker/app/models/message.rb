class Message < ActiveRecord::Base
  include Trackable, BetterJson

  # EVENT TRACKING
  track :added

  # NOTIFICATION SUBSCRIPTIONS
  subscribe :recipient_users, to: [:added]

  # ASSOCIATIONS
  belongs_to :submitter, :class_name => 'User', :foreign_key => 'submitted_by', :inverse_of => 'sent_messages'
  belongs_to :recipient, :class_name => 'User', :foreign_key => 'sent_to', :inverse_of => 'messages'

  # VALIDATIONS
  validates :submitted_by, :text, presence: true
  validates :text, length: { in: 8..32768 }

  # TODO: We should probably do something to make global message notification performant for when we have more than 10,000 users
  def recipient_users
    sent_to ? recipient : User.all
  end

  # Private methods
  private
    def set_dates
      if self.submitted.nil?
        self.submitted = DateTime.now
      else
        self.edited = DateTime.now
      end
    end
end