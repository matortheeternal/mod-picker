class ModListIgnoredNote < ActiveRecord::Base
  include BetterJson

  belongs_to :mod_list, :inverse_of => 'ignored_notes'
  belongs_to :note, :polymorphic => true

  # VALIDATIONS
  validates :mod_list_id, :note_id, :note_type, presence: true

  # CALLBACKS
  after_create :increment_counters
  before_destroy :decrement_counters

  def self.base_json_format
    { :except => [:mod_list_id] }
  end
  
  # Private Methods
  private
    # counter caches
    def increment_counters
      self.mod_list.update_counter(:ignored_notes_count, 1)
    end

    def decrement_counters
      self.mod_list.update_counter(:ignored_notes_count, -1)
    end
end
