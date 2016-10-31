class ModListCustomPlugin < ActiveRecord::Base
  include BetterJson, CounterCache, ScopeHelpers

  # SCOPES
  nil_scope :group_id, alias: 'orphans'

  # ASSOCIATIONS
  belongs_to :mod_list, :inverse_of => 'custom_plugins'

  # COUNTER CACHE
  counter_cache_on :mod_list, column: 'custom_plugins_count'

  # VALIDATIONS
  validates :mod_list_id, :index, :filename, presence: true
  validates :merged, :cleaned, inclusion: [true, false]
  validates :description, length: {maximum: 4096}
end
