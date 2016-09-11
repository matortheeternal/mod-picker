class Message < ActiveRecord::Base
  # ASSOCIATIONS
  belongs_to :submitter, :class_name => 'User', :foreign_key => 'submitted_by', :inverse_of => 'sent_messages'
  belongs_to :recipient, :class_name => 'User', :foreign_key => 'sent_to', :inverse_of => 'messages'

  # VALIDATIONS
  validates :submitted_by, :text, presence: true
  validates :text, length: { in: 8..32768 }

  def notification_json_options(event_type)
    { :only => [:text] }
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