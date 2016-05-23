class Report < ActiveRecord::Base
  belongs_to :base_report, :inverse_of => 'reports'
  belongs_to :user, :foreign_key => 'submitted_by', :inverse_of => 'reports'

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
