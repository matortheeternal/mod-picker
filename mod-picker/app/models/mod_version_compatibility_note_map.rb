class ModVersionCompatibilityNoteMap < ActiveRecord::Base
  belongs_to :mod_version, :inverse_of => 'mod_version_compatibility_notes'
  belongs_to :compatibility_note, :inverse_of => 'mod_version_compatibility_notes'
end
