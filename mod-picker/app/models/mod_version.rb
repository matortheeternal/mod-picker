class ModVersion < ActiveRecord::Base
  belongs_to :mod, :inverse_of => 'mod_versions'
  has_many :plugins, :inverse_of => 'mod_version'

  has_many :installation_notes, :inverse_of => 'mod_version'
  has_many :mod_version_compatibility_notes, :inverse_of => 'mod_version'
  has_many :compatibility_notes, :through => 'ModVersionCompatibilityNote', :inverse_of => 'mod_versions'

  has_many :mod_version_files, :inverse_of => 'mod_version'
  has_many :asset_files, :class_name => 'ModAssetFile', :through => 'ModVersionFile', :inverse_of => 'mod_versions'
end
