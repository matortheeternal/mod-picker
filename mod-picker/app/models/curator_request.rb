class CuratorRequest < ActiveRecord::Base
  include RecordEnhancements, BetterJson, CounterCache, ScopeHelpers, Filterable, Sortable, Dateable

  # ATTRIBUTES
  enum state: [:open, :approved, :denied]

  # DATE COLUMNS
  date_column :submitted, :updated

  # ASSOCIATIONS
  belongs_to :user, :inverse_of => 'curator_requests'
  belongs_to :mod, :inverse_of => 'curator_requests'

  # VALIDATIONS
  validates :user_id, :mod_id, :message, presence: true
end
