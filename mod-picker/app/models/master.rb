class Master < ActiveRecord::Base
  include ScopeHelpers, BetterJson

  self.primary_keys = :plugin_id, :master_plugin_id

  # SCOPES
  ids_scope :plugin_id

  # UNIQUE SCOPES
  scope :visible, -> {
    eager_load(:plugin => :mod, :master_plugin => :mod).where(:mods => {hidden: false}).where(:mods_plugins => {hidden: false})
  }

  # ASSOCIATIONS
  belongs_to :plugin, :inverse_of => 'masters'
  belongs_to :master_plugin, :class_name => 'Plugin', :foreign_key => 'master_plugin_id', :inverse_of => 'children'

  # VALIDATIONS
  validates :plugin_id, :master_plugin_id, :index, presence: true
end
