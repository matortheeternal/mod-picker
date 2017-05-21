class ModListPlugin < ActiveRecord::Base
  include RecordEnhancements, BetterJson, CounterCache, ScopeHelpers

  # SCOPES
  ids_scope :plugin_id
  nil_scope :group_id, alias: 'orphans'

  # UNIQUE SCOPES
  scope :official, -> (bool) {
    joins(:plugin => :mod).where(:mods => { is_official: bool })
  }

  # ASSOCIATIONS
  belongs_to :mod_list, :inverse_of => 'mod_list_plugins'
  belongs_to :plugin, :inverse_of => 'mod_list_plugins'
  has_one :mod, :through => 'plugin'

  # COUNTER CACHE
  counter_cache_on :mod_list, column: 'plugins_count'
  counter_cache_on :plugin, column: 'mod_lists_count'

  # VALIDATIONS
  validates :mod_list_id, :plugin_id, :index, presence: true
  validates :cleaned, :merged, inclusion: [true, false]
  # can only have a mod on a given mod list once
  validates :plugin_id, uniqueness: { scope: :mod_list_id, :message => "The plugin is already present on the mod list." }

  def self.create_from_custom_plugin(custom_plugin, plugins)
    plugin_to_add = plugins.detect {|p| p.filename == custom_plugin.filename}
    return unless plugin_to_add.present?
    create({
        mod_list_id: custom_plugin.mod_list_id,
        group_id: custom_plugin.group_id,
        plugin_id: plugin_to_add.id,
        index: custom_plugin.index
    })
  end

  def self.replace_with_custom(mod)
    ModListPlugin.where(plugin_id: mod.plugin_ids).find_each do |mod_list_plugin|
      ModListCustomPlugin.create_from_mod_list_plugin(mod_list_plugin)
      mod_list_plugin.destroy
    end
  end

  def required_plugins
    Master.plugins([self.plugin_id]).order(:master_plugin_id)
  end

  def plugin_filename
    plugin.filename
  end

  def copy_attributes(mod_list_id, index, group_id)
    attributes.except("id").merge({ mod_list_id: mod_list_id, index: index, group_id: group_id })
  end

  def copy_to(other_mod_list, index, new_group_id=nil)
    unless other_mod_list.mod_list_plugins.plugins(plugin_id).exists?
      ModListPlugin.create(copy_attributes(other_mod_list.id, index, new_group_id))
    end
  end
end
