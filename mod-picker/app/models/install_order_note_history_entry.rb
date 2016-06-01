class InstallOrderNoteHistoryEntry < ActiveRecord::Base
  belongs_to :install_order_note, :inverse_of => 'install_order_note_history_entries'
  belongs_to :user, :foreign_key => 'submitted_by', :inverse_of => 'install_order_note_history_entries'

  # Callbacks
  after_create :increment_counters
  before_destroy :decrement_counters

  private
    def increment_counters
      self.install_order_note.update_counter(:history_entries_count, 1)
    end

    def decrement_counters
      self.install_order_note.update_counter(:history_entries_count, -1)
    end
end