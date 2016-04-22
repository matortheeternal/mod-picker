class ModVersion < ActiveRecord::Base
  after_create :increment_counter_caches
  before_destroy :decrement_counter_caches

  belongs_to :mod, :inverse_of => 'mod_versions'
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
  has_many :required_by, :class_name => 'ModVersionRequirement', :inverse_of => 'required_mod_version', :foreign_key => 'required_id'

  def required_mods
    @mods = []
    self.requires.each do |r|
      mod = r.required_mod_version.mod
      @mods.push({
        id: mod.id,
        name: mod.name,
        mod_version_id: r.required_id,
        version: r.required_mod_version.version
      })
    end
    @mods
  end

  private
    def increment_counter_caches
      self.mod.mod_versions_count += 1
      self.mod.save
    end

    def decrement_counter_caches
      self.mod.mod_versions_count -= 1
      self.mod.save
    end
end
