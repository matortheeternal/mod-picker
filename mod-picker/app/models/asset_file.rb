class AssetFile < ActiveRecord::Base
  include RecordEnhancements, BetterJson, CounterCache

  belongs_to :game, :inverse_of => 'asset_files'

  has_many :mod_asset_files, :inverse_of => 'asset_file', :dependent => :destroy
  has_many :mod_options, :through => 'mod_asset_files', :inverse_of => 'asset_files'

  # VALIDATIONS
  validates :game_id, :path, presence: true
end
