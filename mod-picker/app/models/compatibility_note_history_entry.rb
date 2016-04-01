class CompatibilityNoteHistoryEntry < ActiveRecord::Base
  belongs_to :compatibility_note, :inverse_of => 'compatibility_note_history_entries'
  belongs_to :user, :foreign_key => 'submitted_by', :inverse_of => 'compatibility_note_history_entries'
end
