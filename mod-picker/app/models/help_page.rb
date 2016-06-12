class HelpPage < ActiveRecord::Base
  include RecordEnhancements

  belongs_to :submitter, :class_name => 'User', :foreign_key => 'submitted_by', :inverse_of => 'help_pages'

  has_many :comments, :as => 'commentable'

  # validations
  validates :name, :text_body, presence: true
  validates :name, length: {in: 4..128}
  validates :text_body, length: {in: 64..32768}

  # Callbacks
  before_save :set_dates

  private
    def set_dates
      if self.submitted.nil?
        self.submitted = DateTime.now
      else
        self.edited = DateTime.now
      end
    end
end
