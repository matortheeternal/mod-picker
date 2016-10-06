class CompatibilityNoteHistoryEntry < ActiveRecord::Base
  include BetterJson

  belongs_to :compatibility_note, :inverse_of => 'history_entries', :foreign_key => 'compatibility_note_id'
  belongs_to :editor, :class_name => 'User', :foreign_key => 'edited_by', :inverse_of => 'compatibility_note_history_entries'

  enum status: [ :incompatible, :partially_incompatible, :compatibility_mod, :compatibility_option, :make_custom_patch ]

  # VALIDATIONS
  validates :compatibility_note_id, :edited_by, :status, :text_body, :edit_summary, presence: true

  # CALLBACKS
  after_create :increment_counters
  before_destroy :decrement_counters

  private
    def increment_counters
      self.compatibility_note.update_counter(:history_entries_count, 1)
    end

    def decrement_counters
      self.compatibility_note.update_counter(:history_entries_count, -1)
    end
end
