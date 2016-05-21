class BaseReport < EnhancedRecord::Base
  belongs_to :reportable, :polymorphic => true
  has_many :reports, :inverse_of => 'base_report'

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
