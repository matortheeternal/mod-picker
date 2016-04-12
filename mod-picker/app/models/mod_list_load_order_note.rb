class ModListLoadOrderNote < ActiveRecord::Base
  self.primary_keys = :mod_list_id, :load_order_note_id

  enum status: [ :unresolved, :resolved, :ignored ]

  belongs_to :load_order_note, :inverse_of => 'mod_list_load_order_notes'
  belongs_to :mod_list, :inverse_of => 'mod_list_load_order_notes'
end
