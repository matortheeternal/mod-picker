class Report < ActiveRecord::Base
  include RecordEnhancements, BetterJson, Dateable

  # ATTRIBUTES
  enum reason: [:be_respectful, :be_trustworthy, :be_constructive, :spam, :piracy, :adult_content, :other]

  # DATE COLUMNS
  date_column :submitted, :edited

  # ASSOCIATIONS
  belongs_to :base_report, :inverse_of => 'reports'
  belongs_to :submitter, :class_name => 'User', :foreign_key => 'submitted_by', :inverse_of => 'reports'

  # COUNTER CACHE
  counter_cache_on :base_report

  # VALIDATIONS
  validates :base_report_id, :submitted_by, :reason, presence: true
  validates :note, length: {maximum: 128}
end
