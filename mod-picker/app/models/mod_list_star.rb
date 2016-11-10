class ModListStar < ActiveRecord::Base
  include RecordEnhancements, BetterJson, CounterCache

  # ATTRIBUTES
  self.primary_keys = :mod_list_id, :user_id

  # ASSOCIATIONS
  belongs_to :user, :inverse_of => 'mod_list_stars'
  belongs_to :mod_list, :inverse_of => 'stars'

  # COUNTER CACHE
  counter_cache_on :user, column: 'starred_mod_lists_count'
  counter_cache_on :mod_list, column: 'stars_count'

  # VALIDATIONS
  validates :mod_list_id, :user_id, presence: true
end
