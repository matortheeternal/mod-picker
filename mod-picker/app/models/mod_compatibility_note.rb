class ModCompatibilityNote < ActiveRecord::Base
  include BetterJson

  # ATTRIBUTES
  self.primary_keys = :mod_id, :compatibility_note_id

  # ASSOCIATIONS
  belongs_to :mod, :inverse_of => 'mod_compatibility_notes'
  belongs_to :compatibility_note, :inverse_of => 'mod_compatibility_notes'
end