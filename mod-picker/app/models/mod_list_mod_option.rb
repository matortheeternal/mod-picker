class ModListModOption < ActiveRecord::Base
  include ScopeHelpers, BetterJson

  # SCOPES
  value_scope :is_utility, association: 'mod'
  value_scope :is_official, association: 'mod'
  ids_scope :mod_option_id

  # ASSOCIATIONS
  belongs_to :mod_list_mod, :inverse_of => 'mod_list_mod_options'
  belongs_to :mod_option, :inverse_of => 'mod_list_mod_options'

  has_one :mod, :through => :mod_list_mod

  # VALIDATIONS
  validates :mod_list_mod_id, :mod_option_id, presence: true

  def copy_attributes(mod_list_mod_id)
    attributes.except("id").merge({ mod_list_mod_id: mod_list_mod_id })
  end

  def copy_to(other_mod_list_mod)
    unless other_mod_list_mod.mod_list_mod_options.mod_options(mod_option_id).exists?
      ModListModOption.create(copy_attributes(other_mod_list_mod.id))
    end
  end

  def add_plugins
    mod_list = mod_list_mod.mod_list
    plugin_ids = mod_list.mod_list_plugin_ids
    index = mod_list.plugins_count + 1
    mod_option.plugins.each do |plugin|
      next if plugin_ids.include?(plugin.id)
      ModListPlugin.create!({
          mod_list_id: mod_list.id,
          plugin_id: plugin.id,
          index: index
      })
      index += 1
    end
  end
end
