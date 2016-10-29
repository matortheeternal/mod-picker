class ModListModOption < ActiveRecord::Base
  include ScopeHelpers, BetterJson

  # SCOPES
  scope :utility, -> (bool) { joins(:mod).where(:mods => {:is_utility => bool})}
  scope :official, -> (bool) { joins(:mod).where(:mods => {:is_official => bool})}

  # ASSOCIATIONS
  belongs_to :mod_list_mod, :inverse_of => 'mod_list_mod_options'
  belongs_to :mod_option, :inverse_of => 'mod_list_mod_options'

  has_one :mod, :through => :mod_list_mod

  # VALIDATIONS
  validates :mod_list_mod_id, :mod_option_id, presence: true

  private
    def add_plugins
      mod_list = mod_list_mod.mod_list
      plugin_ids = mod_list.mod_list_plugin_ids
      mod_option.plugins.each do |plugin|
        next if plugin_ids.include?(plugin.id)
        ModListPlugin.create!({
            mod_list_id: mod_list.id,
            plugin_id: plugin.id,
            index: mod_list.plugins_count + 1
        })
      end
    end
end
