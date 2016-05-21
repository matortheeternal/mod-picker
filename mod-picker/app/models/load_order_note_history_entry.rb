class LoadOrderNoteHistoryEntry < EnhancedRecord::Base
  belongs_to :load_order_note, :inverse_of => 'load_order_note_history_entries'
  belongs_to :user, :foreign_key => 'submitted_by', :inverse_of => 'load_order_note_history_entries'
end