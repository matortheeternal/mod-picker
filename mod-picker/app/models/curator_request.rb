class CuratorRequest < ActiveRecord::Base
  include RecordEnhancements, BetterJson, CounterCache, ScopeHelpers, Filterable, Sortable, Dateable

  # ATTRIBUTES
  enum state: [:open, :approved, :denied]

  # DATE COLUMNS
  date_column :submitted, :updated

  # SCOPES
  search_scope :message
  user_scope :user
  enum_scope :state
  date_scope :submitted, :updated
  range_scope :released, association: 'mod', alias: 'mod_released'
  range_scope :updated, association: 'mod', alias: 'mod_updated'

  # UNIQUE SCOPES
  scope :mod_name, -> (name) { where("mods.name LIKE ?", "%#{name}%") }
  scope :user_reputation, -> (range) { where(users: { user_reputations: (range[:min]..range[:max]) }) }

  # ASSOCIATIONS
  belongs_to :user, :inverse_of => 'curator_requests'
  belongs_to :mod, :inverse_of => 'curator_requests'

  # VALIDATIONS
  validates :user_id, :mod_id, :message, presence: true
end
