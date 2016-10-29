class InstallOrderNoteHistoryEntry < ActiveRecord::Base
  include BetterJson, CounterCache

  # ASSOCIATIONS
  belongs_to :install_order_note, :inverse_of => 'history_entries', :foreign_key => 'install_order_note_id'
  belongs_to :editor, :class_name => 'User', :foreign_key => 'edited_by', :inverse_of => 'install_order_note_history_entries'

  # COUNTER CACHE
  counter_cache_on :install_order_note, column: 'history_entries_count'

  # VALIDATIONS
  validates :install_order_note_id, :edited_by, :text_body, presence: true
end