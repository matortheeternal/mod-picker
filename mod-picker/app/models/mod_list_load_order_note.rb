class ModListLoadOrderNote < ActiveRecord::Base
  belongs_to :load_order_note
  belongs_to :mod_list
end
