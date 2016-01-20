class ModVersionFileMap < ActiveRecord::Base
  belongs_to :mod_version, :inverse_of => 'mod_version_file_maps'
  belongs_to :mod_asset_file, :inverse_of => 'mod_version_file_maps'
end
