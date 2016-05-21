class InstallOrderNoteHistoryEntry < EnhancedRecord::Base
  belongs_to :install_order_note, :inverse_of => 'install_order_note_history_entries'
  belongs_to :user, :foreign_key => 'submitted_by', :inverse_of => 'install_order_note_history_entries'
end