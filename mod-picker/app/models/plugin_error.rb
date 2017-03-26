class PluginError < ActiveRecord::Base
  include ScopeHelpers, BetterJson

  # SCOPES
  ids_scope :plugin_id

  # UNIQUE SCOPES
  scope :mod_list, -> (mod_list_id) { joins("INNER JOIN mod_list_plugins").where("mod_list_plugins.mod_list_id = ?", mod_list_id).where("mod_list_plugins.plugin_id = plugin_errors.plugin_id").distinct }

  # ASSOCIATIONS
  belongs_to :plugin, :inverse_of => 'errors'

  # VALIDATIONS
  validates :signature, :form_id, :group, presence: true

  validates :signature, length: {is: 4}
  validates :path, :name, length: {maximum: 400}
  validates :data, length: {maximum: 255}

  belongs_to :plugin, :inverse_of => 'plugin_errors'
end
