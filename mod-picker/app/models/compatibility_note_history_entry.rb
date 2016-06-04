class CompatibilityNoteHistoryEntry < ActiveRecord::Base
  belongs_to :compatibility_note, :inverse_of => 'compatibility_note_history_entries'
  belongs_to :user, :foreign_key => 'submitted_by', :inverse_of => 'compatibility_note_history_entries'

  enum status: [ :incompatible, :"partially incompatible", :"compatibility mod", :"compatibility option", :"make custom patch" ]

  # Callbacks
  after_initialize :init
  after_create :increment_counters
  before_destroy :decrement_counters

  # Validations
  validates :submitted_by, :text_body, presence: true

  private
    def init
      self.submitted ||= DateTime.now
    end
    def increment_counters
      self.compatibility_note.update_counter(:history_entries_count, 1)
    end

    def decrement_counters
      self.compatibility_note.update_counter(:history_entries_count, -1)
    end
end
