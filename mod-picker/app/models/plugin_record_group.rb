class PluginRecordGroup < ActiveRecord::Base
  include ScopeHelpers, BetterJson

  self.primary_keys = :plugin_id, :sig

  # Scopes
  ids_scope :plugin_id

  # ASSOCIATIONS
  belongs_to :plugin, :inverse_of => 'plugin_record_groups'

  # VALIDATIONS
  validates :sig, :record_count, :override_count, presence: true
  validates :sig, length: {is: 4}
end
