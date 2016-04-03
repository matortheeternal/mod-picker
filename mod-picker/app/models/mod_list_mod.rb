class ModListMod < ActiveRecord::Base
  self.primary_keys = :mod_list_id, :mod_id

  belongs_to :mod_list, :inverse_of => 'mod_list_mods'
  belongs_to :mod, :inverse_of => 'mod_list_mods'
end
