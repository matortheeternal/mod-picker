class CuratorRequest < ActiveRecord::Base
  include RecordEnhancements, BetterJson, CounterCache, ScopeHelpers, Filterable, Sortable, Dateable

  # ATTRIBUTES
  enum state: [:open, :approved, :denied]

  # DATE COLUMNS
  date_column :submitted, :updated

  # SCOPES
  search_scope :text_body, alias: 'search'
  user_scope :submitter
  enum_scope :state
  date_scope :submitted, :updated

  # UNIQUE SCOPES
  scope :mod_name, -> (name) { where("mods.name LIKE ?", "%#{name}%") }

  # ASSOCIATIONS
  belongs_to :submitter, :class_name => 'User', :foreign_key => 'submitted_by', :inverse_of => 'curator_requests'
  belongs_to :mod, :inverse_of => 'curator_requests'

  # VALIDATIONS
  validates :submitted_by, :mod_id, :text_body, presence: true
end
