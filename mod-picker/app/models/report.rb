class Report < ActiveRecord::Base
  include RecordEnhancements

  enum reason: [:be_respectful, :be_trustworthy, :be_constructive, :no_spam, :no_piracy, :adult_content, :other]

  belongs_to :base_report, :inverse_of => 'reports'
  belongs_to :submitter, :class_name => 'User', :foreign_key => 'submitted_by', :inverse_of => 'reports'

  # Validations
  validates :base_report_id, :submitted_by, :reason, presence: true
  validates :note, length: {maximum: 128}

  # CALLBACKS
  after_create :increment_counters
  before_destroy :decrement_counters
  before_save :set_dates

  private
    def increment_counters
      base_report.update_counter(:reports_count, 1)
    end

    def decrement_counters
      base_report.update_counter(:reports_count, -1)
    end

    def set_dates
      if submitted.nil?
        self.submitted = DateTime.now
      else
        self.edited = DateTime.now
      end
    end
end
