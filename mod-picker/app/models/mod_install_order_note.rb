class ModInstallOrderNote < ActiveRecord::Base
  include BetterJson

  # ATTRIBUTES
  self.primary_keys = :mod_id, :install_order_note_id

  # ASSOCIATIONS
  belongs_to :mod, :inverse_of => 'mod_install_order_notes'
  belongs_to :install_order_note, :inverse_of => 'mod_install_order_notes'
end