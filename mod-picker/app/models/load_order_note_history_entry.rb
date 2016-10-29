class LoadOrderNoteHistoryEntry < ActiveRecord::Base
  include BetterJson, CounterCache

  # ASSOCIATIONS
  belongs_to :load_order_note, :inverse_of => 'history_entries', :foreign_key => 'load_order_note_id'
  belongs_to :editor, :class_name => 'User', :foreign_key => 'edited_by', :inverse_of => 'load_order_note_history_entries'

  # COUNTER CACHE
  counter_cache_on :load_order_note, column: 'history_entries_count'

  # VALIDATIONS
  validates :load_order_note_id, :edited_by, :text_body, presence: true
end