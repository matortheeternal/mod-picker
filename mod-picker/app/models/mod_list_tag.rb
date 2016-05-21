class ModListTag < EnhancedRecord::Base
  self.primary_keys = :mod_list_id, :tag_id

  belongs_to :mod_list, :inverse_of => 'mod_list_tags'
  belongs_to :tag, :inverse_of => 'mod_list_tags'
  belongs_to :user, :inverse_of => 'mod_list_tags'

  # Validations
  validates :tag, :mod_list_id, :submitted_by, presence: true

  # Callbacks
  after_create :increment_counters
  before_destroy :decrement_counters

  private
    def increment_counters
      self.mod_list.update_counter(:tags_count, 1)
      self.tag.update_counter(:mod_lists_count, 1)
    end

    def decrement_counters
      self.mod_list.update_counter(:tags_count, -1)
      self.tag.update_counter(:mod_lists_count, -1)
    end
end
