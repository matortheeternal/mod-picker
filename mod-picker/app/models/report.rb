class Report < ActiveRecord::Base
  belongs_to :base_report, :inverse_of => 'reports'
  belongs_to :submitter, :class_name => 'User', :foreign_key => 'submitted_by', :inverse_of => 'reports'

  # Validations
  validates :base_report_id, :submitted_by, :type, presence: true
  validates :note, length: {maximum: 128}

  # Callbacks
  after_create :increment_counters
  before_destroy :decrement_counters

  private
    def increment_counters
      self.base_report.update_counter(:reports_count, 1)
    end

    def decrement_counters
      self.base_report.update_counter(:reports_count, -1)
    end
end
