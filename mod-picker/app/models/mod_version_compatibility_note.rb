class ModVersionCompatibilityNote < ActiveRecord::Base
  belongs_to :mod_version, :inverse_of => 'ModVersionCompatibilityNote'
  belongs_to :compatibility_note, :inverse_of => 'ModVersionCompatibilityNote'
end
