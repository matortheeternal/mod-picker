class PluginRecordGroup < ActiveRecord::Base
  include ScopeHelpers

  self.primary_keys = :plugin_id, :sig

  # Scopes
  ids_scope :plugin_id

  # Associations
  belongs_to :plugin, :inverse_of => 'plugin_record_groups'

  # Validations
  validates :sig, :record_count, :override_count, presence: true
  validates :sig, length: {is: 4}
end
