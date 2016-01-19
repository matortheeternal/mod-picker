class ModAssetFile < ActiveRecord::Base
  belongs_to :mod, :inverse_of => 'asset_files'
end
