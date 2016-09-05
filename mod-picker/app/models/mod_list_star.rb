class ModListStar < ActiveRecord::Base
  self.primary_keys = :mod_list_id, :user_id

  belongs_to :user, :inverse_of => 'mod_list_stars'
  belongs_to :mod_list, :inverse_of => 'mod_list_stars'

  # VALIDATIONS
  validates :mod_list_id, :user_id, presence: true

  # CALLBACKS
  after_create :increment_counters
  before_destroy :decrement_counters

  private
    def increment_counters
      self.user.update_counter(:starred_mod_lists_count, 1)
      self.mod_list.update_counter(:stars_count, 1)
    end

    def decrement_counters
      self.user.update_counter(:starred_mod_lists_count, -1)
      self.mod_list.update_counter(:stars_count, -1)
    end
end
