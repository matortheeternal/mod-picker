class ModListInstallOrderNote < ActiveRecord::Base
  belongs_to :install_order_note, :inverse_of => 'mod_list_install_order_notes'
  belongs_to :mod_list, :inverse_of => 'mod_list_install_order_notes'
end
