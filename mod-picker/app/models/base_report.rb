class BaseReport < ActiveRecord::Base
  include Filterable, Sortable, RecordEnhancements

  scope :note, -> (search) { where("reports.note like ?", "%#{search}%") }
  scope :submitter, -> (search) { where("reports.submitter.username like ?", "#{search}%") }
  scope :submitted, -> (range) { where(submitted: parseDate(range[:min])..parseDate(range[:max])) }
  scope :edited, -> (range) { where(edited: parseDate(range[:min])..parseDate(range[:max])) }
  scope :reportable, -> (reportable_hash) {
    # build reportables array
    reportables = []
    reportable_hash.each_key do |key|
      if reportable_hash[key]
        reportables.push(key)
      end
    end

    # return query
    where(reportable_type: reportables)
  }
  scope :report_type, -> (report_type_hash) {
    # build report_type array
    report_types = []
    report_type_hash.each_key do |key|
      if report_type_hash[key]
        report_types.push(key)
      end
    end

    # return query
    where(reports.report_type => report_types)
  }

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
