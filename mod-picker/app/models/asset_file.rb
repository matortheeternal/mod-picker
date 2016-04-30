class AssetFile < ActiveRecord::Base
  has_many :mod_asset_files, :inverse_of => 'asset_file'
  has_many :mods, :through => 'mod_asset_files', :inverse_of => 'asset_files'

  validates :filepath, presence: true
end
