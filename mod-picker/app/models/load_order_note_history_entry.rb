class LoadOrderNoteHistoryEntry < ActiveRecord::Base
  belongs_to :load_order_note, :inverse_of => 'history_entries', :foreign_key => 'load_order_note_id'
  belongs_to :editor, :class_name => 'User', :foreign_key => 'edited_by', :inverse_of => 'load_order_note_history_entries'

  # Callbacks
  after_create :increment_counters
  before_destroy :decrement_counters

  private
    def increment_counters
      self.load_order_note.update_counter(:history_entries_count, 1)
    end

    def decrement_counters
      self.load_order_note.update_counter(:history_entries_count, -1)
    end
end