class ModListInstallOrderNote < ActiveRecord::Base
  self.primary_keys = :mod_list_id, :install_order_note_id

  belongs_to :install_order_note, :inverse_of => 'mod_list_install_order_notes'
  belongs_to :mod_list, :inverse_of => 'mod_list_install_order_notes'
end
