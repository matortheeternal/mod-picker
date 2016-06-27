class ModListCompatibilityNote < ActiveRecord::Base

  self.primary_keys = :mod_list_id, :compatibility_note_id

  enum status: [ :unresolved, :resolved, :ignored ]

  belongs_to :mod_list, :inverse_of => 'mod_list_compatibility_notes'
  belongs_to :compatibility_note, :inverse_of => 'mod_list_compatibility_notes'

  # Validations
  validates :mod_list_id, :compatibility_note_id, presence: true

  # Callbacks
  after_create :increment_counters
  before_destroy :decrement_counters
  
  # Private Methods
  private
    # counter caches
    def increment_counters
      self.mod_list.compatibility_notes_count += 1
      self.mod_list.save
    end

    def decrement_counters
      self.mod_list.compatibility_notes_count -= 1
      self.mod_list.save
    end 

end
