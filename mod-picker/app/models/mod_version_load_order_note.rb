class ModVersionLoadOrderNote < ActiveRecord::Base
  belongs_to :mod_version, :inverse_of => 'mod_version_load_order_notes'
  belongs_to :load_order_note, :inverse_of => 'mod_version_load_order_notes'
end
