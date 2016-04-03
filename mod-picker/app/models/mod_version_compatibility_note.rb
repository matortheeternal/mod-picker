class ModVersionCompatibilityNote < ActiveRecord::Base
  self.primary_keys = :mod_version_id, :compatibility_note_id

  belongs_to :mod_version, :inverse_of => 'mod_version_compatibility_notes'
  belongs_to :compatibility_note, :inverse_of => 'mod_version_compatibility_notes'
end
