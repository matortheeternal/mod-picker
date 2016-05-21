class ModListStar < EnhancedRecord::Base
  after_create :increment_counter_caches
  before_destroy :decrement_counter_caches

  self.primary_keys = :mod_list_id, :user_id

  belongs_to :user, :inverse_of => 'mod_list_stars'
  belongs_to :mod_list, :inverse_of => 'mod_list_stars'

  # Validations
  validates :mod_list_id, :user_id, presence: true

  # Private Methods
  private
    # counter caches for mod_list counts
    def increment_counter_caches
      self.starred_mod_list.user_stars_count += 1
      self.starred_mod_list.save
    end

    def decrement_counter_caches
      self.starred_mod_list.user_stars_count -= 1
      self.starred_mod_list.save
    end 
end
