class ModListCompatibilityNote < ActiveRecord::Base
  self.primary_keys = :mod_list_id, :compatibility_note_id

  belongs_to :mod_list, :inverse_of => 'mod_list_compatibility_notes'
  belongs_to :compatibility_note, :inverse_of => 'mod_list_compatibility_notes'

  # validations
  validates :mod_list_id, :compatibility_note_id, presence: true
  validates :status, inclusion: {in: ["Unresolved", "Resolved", "Ignored"],
                                 message: "Not a valid compatibility note status"}
end
