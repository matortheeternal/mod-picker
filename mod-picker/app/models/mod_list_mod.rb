class ModListMod < ActiveRecord::Base
  include RecordEnhancements, ScopeHelpers, BetterJson, CounterCache

  # SCOPES
  value_scope :is_utility
  value_scope :is_official, :association => 'mod'

  # ASSOCIATIONS
  belongs_to :mod_list, :inverse_of => 'mod_list_mods'
  belongs_to :mod, :inverse_of => 'mod_list_mods'

  has_many :mod_list_mod_options, :inverse_of => 'mod_list_mod', :dependent => :destroy

  # NESTED ATTRIBUTES
  accepts_nested_attributes_for :mod_list_mod_options, allow_destroy: true

  # COUNTER CACHE
  counter_cache_on :mod, column: 'mod_lists_count'
  bool_counter_cache_on :mod_list, :is_utility, { true => :tools, false => :mods }

  # VALIDATIONS
  validates :mod_list_id, :mod_id, presence: true
  validates :mod_id, uniqueness: { scope: :mod_list_id, :message => "The mod is already present on the mod list." }
  validates :is_utility, inclusion: [true, false]

  # CALLBACKS
  before_create :set_index_and_is_utility
  after_create :add_default_mod_options
  before_destroy :destroy_mod_list_plugins

  def mod_compatibility_notes
    mod_ids = mod_list.mod_list_mod_ids
    return [] if mod_ids.empty?

    CompatibilityNote.visible.mod(mod_ids).mod([mod_id]).status([0, 1, 2])
  end

  def plugin_compatibility_notes
    mod_ids = mod_list.mod_list_mod_ids
    return [] if mod_ids.empty?

    CompatibilityNote.visible.mods(mod_ids).mod([mod_id]).status([3, 4])
  end

  def install_order_notes
    mod_ids = mod_list.mod_list_mod_ids
    return [] if mod_ids.empty?

    InstallOrderNote.visible.mod(mod_ids).mod([mod_id])
  end

  def load_order_notes
    plugin_ids = mod_list.mod_list_plugin_ids
    return [] if plugin_ids.empty?

    LoadOrderNote.visible.plugin(plugin_ids).plugin(mod.plugins.ids)
  end

  def required_tools
    ModRequirement.mods(mod_id).utility(true)
  end

  def required_mods
    ModRequirement.mods(mod_id).utility(false)
  end

  def get_index
    self.index = (is_utility ? mod_list.tools_count : mod_list.mods_count) + 1
  end

  def current_plugins
    mod_list.mod_list_plugins.where(plugin_id: mod.plugins.ids)
  end

  private
    def set_index_and_is_utility
      self.is_utility = mod.is_utility
      get_index if self.index.nil?
    end

    def add_default_mod_options
      mod.mod_options.default.each do |mod_option|
        mod_list_mod_option = ModListModOption.create!({
            mod_list_mod_id: id, mod_option_id: mod_option.id
        })
        mod_list_mod_option.add_plugins
      end
    end

    def destroy_mod_list_plugins
      if mod.plugins_count
        plugin_ids = self.mod.plugins.ids
        ModListPlugin.destroy_all(mod_list_id: mod_list_id, plugin_id: plugin_ids)
      end
    end
end
