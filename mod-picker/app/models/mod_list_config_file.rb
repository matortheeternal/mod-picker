class ModListConfigFile < ActiveRecord::Base
  belongs_to :mod_list, :inverse_of => 'config_files'
end
