class ModVersionFile < ActiveRecord::Base
  self.primary_keys = :mod_version_id, :mod_asset_file_id

  belongs_to :mod_version, :inverse_of => 'ModVersionFile'
  belongs_to :mod_asset_file, :inverse_of => 'ModVersionFile'

  # Validations
  validates :mod_version_id, :mod_asset_file_id, presence: true
  
end
