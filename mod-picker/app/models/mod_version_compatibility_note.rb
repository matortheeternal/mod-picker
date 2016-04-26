class ModVersionCompatibilityNote < ActiveRecord::Base
  self.primary_keys = :mod_version_id, :compatibility_note_id

  after_create :increment_counter_caches
  before_destroy :decrement_counter_caches

  belongs_to :mod_version, :inverse_of => 'mod_version_compatibility_notes'
  belongs_to :compatibility_note, :inverse_of => 'mod_version_compatibility_notes'

  # Validations
  validates :mod_version_id, :compatibility_note_id, presence: true
  
  private
    def increment_counter_caches
      self.mod_version.mod.compatibility_notes_count += 1
      self.mod_version.mod.save
    end

    def decrement_counter_caches
      self.mod_version.mod.compatibility_notes_count -= 1
      self.mod_version.mod.save
    end
end
