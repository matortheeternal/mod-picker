class ModStar < ActiveRecord::Base
  include RecordEnhancements, CounterCache, BetterJson

  # ATTRIBUTES
  self.primary_keys = :mod_id, :user_id

  # ASSOCIATIONS
  belongs_to :user, :inverse_of => 'mod_stars'
  belongs_to :mod, :inverse_of => 'mod_stars'

  # COUNTER CACHE
  counter_cache_on :user, column: 'starred_mods_count'
  counter_cache_on :mod, column: 'stars_count'

  # VALIDATIONS
  validates :mod_id, :user_id, presence: true
end
