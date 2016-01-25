class ModListCompatibilityNote < ActiveRecord::Base
  belongs_to :mod_list
  belongs_to :compatibility_note
end
