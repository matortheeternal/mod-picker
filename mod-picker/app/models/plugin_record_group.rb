class PluginRecordGroup < ActiveRecord::Base
  include ScopeHelpers, BetterJson

  self.primary_keys = :plugin_id, :sig

  # Scopes
  ids_scope :plugin_id

  # UNIQUE SCOPES
  scope :mod_list, -> (mod_list_id) { joins("INNER JOIN mod_list_plugins").where("mod_list_plugins.mod_list_id = ?", mod_list_id).where("mod_list_plugins.plugin_id = plugin_record_groups.plugin_id").distinct }

  # ASSOCIATIONS
  belongs_to :plugin, :inverse_of => 'plugin_record_groups'

  # VALIDATIONS
  validates :sig, :record_count, :override_count, presence: true
  validates :sig, length: {is: 4}
end
