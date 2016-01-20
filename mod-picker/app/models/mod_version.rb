class ModVersion < ActiveRecord::Base
  belongs_to :mod, :inverse_of => 'mod_versions'
  has_many :plugins, :inverse_of => 'mod_version'

  has_many :installation_notes, :inverse_of => 'mod_version'
  has_many :compatibility_notes, :through => 'mod_version_compatibility_note_map', :inverse_of => 'mod_versions'

  has_many :mod_version_file_maps, :inverse_of => 'mod_version'
  has_many :asset_files, :class_name => 'ModAssetFile', :through => 'mod_version_file_map', :inverse_of => 'mod_versions'
end
