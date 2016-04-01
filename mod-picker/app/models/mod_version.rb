class ModVersion < ActiveRecord::Base
  belongs_to :mod, :inverse_of => 'mod_versions', :counter_cache => true
  has_many :plugins, :inverse_of => 'mod_version'

  has_many :mod_version_install_order_notes, :inverse_of => 'mod_version'
  has_many :install_order_notes, :through => 'mod_version_install_order_notes', :inverse_of => 'mod_versions'
  has_many :mod_version_load_order_notes, :inverse_of => 'mod_version'
  has_many :load_order_notes, :through => 'mod_version_load_order_notes', :inverse_of => 'mod_versions'
  has_many :mod_version_compatibility_notes, :inverse_of => 'mod_version'
  has_many :compatibility_notes, :through => 'mod_version_compatibility_notes', :inverse_of => 'mod_versions'

  has_many :mod_version_files, :inverse_of => 'mod_version'
  has_many :asset_files, :class_name => 'ModAssetFile', :through => 'mod_version_files', :inverse_of => 'mod_versions'
end
