class ModListInstallationNote < ActiveRecord::Base
  belongs_to :installation_note
  belongs_to :mod_list
end
