class BaseReport < ActiveRecord::Base
  include RecordEnhancements

  belongs_to :reportable, :polymorphic => true
  has_many :reports, :inverse_of => 'base_report'

  # Validations
  validates :reportable_id, :reportable_type, presence: true

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
