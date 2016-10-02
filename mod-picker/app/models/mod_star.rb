class ModStar < ActiveRecord::Base
  include RecordEnhancements

  self.primary_keys = :mod_id, :user_id

  belongs_to :user, :inverse_of => 'mod_stars'
  belongs_to :mod, :inverse_of => 'mod_stars'

  # VALIDATIONS
  validates :mod_id, :user_id, presence: true

  # CALLBACKS
  after_create :increment_counters
  before_destroy :decrement_counters

  private
    def increment_counters
      user.update_counter(:starred_mod_lists_count, 1)
      mod.update_counter(:stars_count, 1)
    end

    def decrement_counters
      user.update_counter(:starred_mod_lists_count, -1)
      mod.update_counter(:stars_count, -1)
    end
end
