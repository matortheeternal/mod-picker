class ModVersion < ActiveRecord::Base
  belongs_to :mod, :inverse_of => 'mod_versions', :counter_cache => true
  has_many :plugins, :inverse_of => 'mod_version'

  # install order, load order, and compatibility notes
  has_many :mod_version_install_order_notes, :inverse_of => 'mod_version'
  has_many :install_order_notes, :through => 'mod_version_install_order_notes', :inverse_of => 'mod_versions'
  has_many :mod_version_load_order_notes, :inverse_of => 'mod_version'
  has_many :load_order_notes, :through => 'mod_version_load_order_notes', :inverse_of => 'mod_versions'
  has_many :mod_version_compatibility_notes, :inverse_of => 'mod_version'
  has_many :compatibility_notes, :through => 'mod_version_compatibility_notes', :inverse_of => 'mod_versions'

  # files associated with this mod version
  has_many :mod_version_files, :inverse_of => 'mod_version'
  has_many :asset_files, :class_name => 'ModAssetFile', :through => 'mod_version_files', :inverse_of => 'mod_versions'

  # requirements
  has_many :requires, :class_name => 'ModVersionRequirement', :inverse_of => 'mod_version'
  has_many :required_by, :class_name => 'ModVersionRequirement', :inverse_of => 'required_mod_version'
end
