class ModVersionFile < ActiveRecord::Base
  self.primary_keys = :mod_version_id, :mod_asset_file_id

  belongs_to :mod_version, :inverse_of => 'mod_version_files'
  belongs_to :mod_asset_file, :inverse_of => 'mod_version_files'

  # Validations
  validates :mod_version_id, :mod_asset_file_id, presence: true

end
