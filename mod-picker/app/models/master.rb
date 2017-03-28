class Master < ActiveRecord::Base
  include ScopeHelpers, BetterJson

  self.primary_keys = :plugin_id, :master_plugin_id

  # SCOPES
  ids_scope :plugin_id

  # UNIQUE SCOPES
  scope :visible, -> {
    eager_load(:plugin => :mod, :master_plugin => :mod).where(:mods => {hidden: false}).where(:mods_plugins => {hidden: false})
  }
  scope :mod_list, -> (mod_list_id) { joins("INNER JOIN mod_list_plugins").where("mod_list_plugins.mod_list_id = ?", mod_list_id).where("mod_list_plugins.plugin_id = masters.plugin_id").distinct }

  # ASSOCIATIONS
  belongs_to :plugin, :inverse_of => 'masters'
  belongs_to :master_plugin, :class_name => 'Plugin', :foreign_key => 'master_plugin_id', :inverse_of => 'children'

  # VALIDATIONS
  validates :plugin_id, :master_plugin_id, :index, presence: true
end
