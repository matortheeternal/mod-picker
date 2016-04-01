class ModListLoadOrderNote < ActiveRecord::Base
  belongs_to :load_order_note, :inverse_of => 'mod_list_load_order_notes'
  belongs_to :mod_list, :inverse_of => 'mod_list_load_order_notes'
end
