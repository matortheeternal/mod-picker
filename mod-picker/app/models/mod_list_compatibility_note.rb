class ModListCompatibilityNote < ActiveRecord::Base
  belongs_to :mod_list, :inverse_of => 'mod_list_compatibility_notes'
  belongs_to :compatibility_note, :inverse_of => 'mod_list_compatibility_notes'
end
