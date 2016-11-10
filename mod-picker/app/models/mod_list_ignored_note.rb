class ModListIgnoredNote < ActiveRecord::Base
  include BetterJson, CounterCache

  # ASSOCIATIONS
  belongs_to :mod_list, :inverse_of => 'ignored_notes'
  belongs_to :note, :polymorphic => true

  # COUNTER CACHE
  counter_cache_on :mod_list, column: 'ignored_notes_count'

  # VALIDATIONS
  validates :mod_list_id, :note_id, :note_type, presence: true
end
