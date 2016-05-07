class ModAssetFile < ActiveRecord::Base
  self.primary_keys = :mod_id, :asset_file_id

  belongs_to :mod, :inverse_of => 'mod_asset_files'
  belongs_to :asset_file, :inverse_of => 'mod_asset_files'
end
