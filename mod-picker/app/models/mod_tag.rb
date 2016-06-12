class ModTag < ActiveRecord::Base
  self.primary_keys = :mod_id, :tag_id

  belongs_to :mod, :inverse_of => 'mod_tags'
  belongs_to :tag, :inverse_of => 'mod_tags'
  belongs_to :submitter, :class_name => 'User', :inverse_of => 'mod_tags', :foreign_key => 'submitted_by'

  # Validations
  validates :tag_id, :mod_id, presence: true

  # Callbacks
  after_create :increment_counters
  before_destroy :decrement_counters

  private
    def increment_counters
      self.mod.update_counter(:tags_count, 1)
      self.tag.update_counter(:mods_count, 1)
      self.submitter.update_counter(:mod_tags_count, 1)
    end

    def decrement_counters
      self.mod.update_counter(:tags_count, -1)
      self.tag.update_counter(:mods_count, -1)
      self.submitter.update_counter(:mod_tags_count, -1)
    end
end
