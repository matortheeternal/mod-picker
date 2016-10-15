class ModListMod < ActiveRecord::Base
  include RecordEnhancements, ScopeHelpers, BetterJson

  # SCOPES
  value_scope :is_utility, :is_official, :association => 'mod'

  # ASSOCIATIONS
  belongs_to :mod_list, :inverse_of => 'mod_list_mods'
  belongs_to :mod, :inverse_of => 'mod_list_mods'

  has_many :mod_list_mod_options, :inverse_of => 'mod_list_mod', :dependent => :destroy

  # NESTED ATTRIBUTES
  accepts_nested_attributes_for :mod_list_mod_options, allow_destroy: true

  # VALIDATIONS
  validates :mod_list_id, :mod_id, :index, presence: true
  # can only have a mod on a given mod list once
  # TODO: If we don't allow the user to change the mod_id with nested attributes we could refactor this validation to be an after_create callback
  validates :mod_id, uniqueness: { scope: :mod_list_id, :message => "The mod is already present on the mod list." }

  # CALLBACKS
  after_create :increment_counter_caches, :add_default_mod_options
  before_destroy :decrement_counter_caches, :destroy_mod_list_plugins

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
    if mod.is_utility
      self.index = mod_list.tools_count + 1
    else
      self.index = mod_list.mods_count + 1
    end
  end

  private
    # counter caches
    def increment_counter_caches
      if mod.is_utility
        mod_list.update_counter(:tools_count, 1)
      else
        mod_list.update_counter(:mods_count, 1)
      end
      mod.update_counter(:mod_lists_count, 1)
    end

    def decrement_counter_caches
      if mod.is_utility
        mod_list.update_counter(:tools_count, -1)
      else
        mod_list.update_counter(:mods_count, -1)
      end
      mod.update_counter(:mod_lists_count, -1)
    end

    def add_default_mod_options
      mod.mod_options.default.each do |mod_option|
        ModListModOption.create!(mod_list_mod_id: id, mod_option_id: mod_option.id)
      end
    end

    def destroy_mod_list_plugins
      if mod.plugins_count
        plugin_ids = self.mod.plugins.ids
        ModListPlugin.destroy_all(mod_list_id: mod_list_id, plugin_id: plugin_ids)
      end
    end
end
