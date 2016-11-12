class BaseReport < ActiveRecord::Base
  include RecordEnhancements, CounterCache, Filterable, Sortable, ScopeHelpers, BetterJson, Dateable

  # DATE COLUMNS
  date_column :submitted, :edited

  # SCOPES
  hash_scope :resolved, alias: 'resolved'
  polymorphic_scope :reportable
  date_scope :submitted
  range_scope :reports_count

  # UNIQUE SCOPES
  # TODO: Expand User scope so we can specify a join like this
  scope :submitter, -> (text) { where("users.username LIKE ?", "#{text}") }
  # TODO: Expand Enum scope so we can specify a join like this
  scope :reason, -> (values) {
    if values.is_a?(Hash)
      array = []
      values.each_key{ |key| array.push(Report.reasons[key]) if values[key] }
    else
      array = values
    end
    where("reports.reason in (?)", array)
  }

  # ASSOCIATIONS
  belongs_to :reportable, :polymorphic => true
  has_many :reports, :inverse_of => 'base_report', :dependent => :destroy

  # COUNTER CACHE
  counter_cache :reports

  # VALIDATIONS
  validates :reportable_id, :reportable_type, presence: true
end
