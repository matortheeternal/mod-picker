class BaseReport < ActiveRecord::Base
  include RecordEnhancements

  belongs_to :reportable, :polymorphic => true
  has_many :reports, :inverse_of => 'base_report'

  # VALIDATIONS
  validates :reportable_id, :reportable_type, presence: true

  # CALLBACKS
  before_save :set_dates

  def self.sortable_columns
    { :except => [] }
  end

  private
    def set_dates
      if self.submitted.nil?
        self.submitted = DateTime.now
      else
        self.edited = DateTime.now
      end
    end
end
