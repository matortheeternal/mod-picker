class Report < ActiveRecord::Base
  include RecordEnhancements, BetterJson, Dateable

  # ATTRIBUTES
  enum reason: [:be_respectful, :be_trustworthy, :be_constructive, :spam, :piracy, :adult_content, :other]

  # DATE COLUMNS
  date_column :submitted, :edited

  # ASSOCIATIONS
  belongs_to :base_report, :inverse_of => 'reports'
  belongs_to :submitter, :class_name => 'User', :foreign_key => 'submitted_by', :inverse_of => 'reports'

  # VALIDATIONS
  validates :base_report_id, :submitted_by, :reason, presence: true
  validates :note, length: {maximum: 128}

  # CALLBACKS
  after_create :increment_counters
  before_destroy :decrement_counters

  private
    def increment_counters
      base_report.update_counter(:reports_count, 1)
    end

    def decrement_counters
      base_report.update_counter(:reports_count, -1)
    end
end
