class BaseReport < ActiveRecord::Base
  include RecordEnhancements, Filterable, Sortable

  belongs_to :reportable, :polymorphic => true
  has_many :reports, :inverse_of => 'base_report'

  # VALIDATIONS
  validates :reportable_id, :reportable_type, presence: true

  # CALLBACKS
  before_save :set_dates

  def as_json(options={})
    if JsonHelpers.json_options_empty(options)
      # include works off of model associations names
      default_options = {
        :include => {
              :reports => {
                  :except => [:base_report_id, :submitted_by],
                  :include => {
                      :submitter => {
                          :only => [:id, :username]
                      }
                  }
              },
              :reportable => reportable.reportable_json_options
          }
      }
      super(options.merge(default_options))
    else
      super(options)
    end
  end

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
