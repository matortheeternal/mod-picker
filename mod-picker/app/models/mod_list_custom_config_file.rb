class ModListCustomConfigFile < ActiveRecord::Base
  belongs_to :mod_list, :inverse_of => 'custom_config_files'
end
