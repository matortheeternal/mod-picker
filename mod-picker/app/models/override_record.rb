class OverrideRecord < ActiveRecord::Base
  include ScopeHelpers, BetterJson

  self.primary_keys = :plugin_id, :fid

  # SCOPES
  ids_scope :plugin_id

  # UNIQUE SCOPES
  scope :mod_list, -> (mod_list_id) { joins("INNER JOIN mod_list_plugins").where("mod_list_plugins.mod_list_id = ?", mod_list_id).where("mod_list_plugins.plugin_id = override_records.plugin_id").distinct }

  # ASSOCIATIONS
  belongs_to :plugin, :inverse_of => 'overrides'
  belongs_to :master, :inverse_of => 'overrides'

  # VALIDATIONS
  validates :fid, :sig, presence: true
  validates :sig, length: {is: 4}
end
