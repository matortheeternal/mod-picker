class ModStar < ActiveRecord::Base
  self.primary_keys = :mod_id, :user_id

  after_create :increment_counter_caches
  before_destroy :decrement_counter_caches

  belongs_to :user, :inverse_of => 'mod_stars'
  belongs_to :mod, :inverse_of => 'mod_stars'

  private
    def increment_counter_caches
      self.mod.mod_stars_count += 1
      self.mod.save
    end

    def decrement_counter_caches
      self.mod.mod_stars_count -= 1
      self.mod.save
    end
end
