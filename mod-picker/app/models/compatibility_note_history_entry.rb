class CompatibilityNoteHistoryEntry < ActiveRecord::Base
  include BetterJson, CounterCache

  # ATTRIBUTES
  enum status: [:incompatible, :partially_incompatible, :compatibility_mod, :compatibility_option, :make_custom_patch]

  # ASSOCIATIONS
  belongs_to :compatibility_note, :inverse_of => 'history_entries', :foreign_key => 'compatibility_note_id'
  belongs_to :editor, :class_name => 'User', :foreign_key => 'edited_by', :inverse_of => 'compatibility_note_history_entries'

  # COUNTER CACHE
  counter_cache_on :compatibility_note, column: 'history_entries_count'

  # VALIDATIONS
  validates :compatibility_note_id, :edited_by, :status, :text_body, presence: true
end
