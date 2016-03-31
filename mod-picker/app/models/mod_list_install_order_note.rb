class ModListInstallOrderNote < ActiveRecord::Base
  belongs_to :install_order_note
  belongs_to :mod_list
end
