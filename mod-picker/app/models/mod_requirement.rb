class ModRequirement < ActiveRecord::Base
  self.primary_keys = :mod_id, :required_id

  belongs_to :mod, :inverse_of => 'required_mods'
  belongs_to :required_mod, :class_name => 'Mod', :inverse_of => 'required_by', :foreign_key => 'required_id'
end
