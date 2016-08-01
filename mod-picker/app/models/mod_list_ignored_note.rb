class ModListIgnoredNote < ActiveRecord::Base
  belongs_to :mod_list, :inverse_of => 'ignored_notes'
  belongs_to :note, :polymorphic => true

  # Validations
  validates :mod_list_id, :note_id, :note_type, presence: true

  # Callbacks
  after_create :increment_counters
  before_destroy :decrement_counters

  def as_json(options={})
    if JsonHelpers.json_options_empty(options)
      default_options = {
          :except => [:mod_list_id]
      }
      super(options.merge(default_options))
    else
      super(options)
    end
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
