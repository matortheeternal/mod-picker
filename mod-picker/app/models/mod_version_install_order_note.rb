class ModVersionInstallOrderNote < ActiveRecord::Base
  self.primary_keys = :mod_version_id, :install_order_note_id

  belongs_to :mod_version, :inverse_of => 'mod_version_install_order_notes'
  belongs_to :install_order_note, :inverse_of => 'mod_version_install_order_notes'
end
