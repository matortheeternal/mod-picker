class Message < ActiveRecord::Base
  # ASSOCIATIONS
  belongs_to :user, :foreign_key => 'submitted_by', :inverse_of => 'messages'

  # VALIDATIONS
  validates :submitted_by, :text, presence: true
  validates :text, length: { in: 8..32768 }

  # Private methods
  private
    def set_dates
      # TODO: Refactor to submitted and edited
      if self.created.nil?
        self.created = DateTime.now
      else
        self.updated = DateTime.now
      end
    end
end