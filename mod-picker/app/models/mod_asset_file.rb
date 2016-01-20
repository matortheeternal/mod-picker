class ModAssetFile < ActiveRecord::Base
  has_many :mod_version_files, :inverse_of => 'mod_asset_file'
  has_many :mod_versions, :through => 'mod_version_files', :inverse_of => 'asset_files'
end
