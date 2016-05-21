class ModTag < EnhancedRecord::Base
  self.primary_keys = :mod_id, :tag_id

  after_create :increment_counter_caches
  before_destroy :decrement_counter_caches

  belongs_to :mod, :inverse_of => 'mod_tags'
  belongs_to :tag, :inverse_of => 'mod_tags'
  belongs_to :user, :inverse_of => 'mod_tags'

  # Validations
  validates :tag, :mod_id, :submitted_by, presence: true

  private
    def increment_counter_caches
      self.tag.mods_count += 1
      self.tag.save
    end

    def decrement_counter_caches
      self.tag.mods_count -= 1
      self.tag.save
    end

end
