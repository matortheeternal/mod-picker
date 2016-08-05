class PluginRecordGroup < ActiveRecord::Base
  self.primary_keys = :plugin_id, :sig

  # Scopes
  scope :plugins, -> (plugin_ids) { where(plugin_id: plugin_ids) }

  # Associations
  belongs_to :plugin, :inverse_of => 'plugin_record_groups'

  # Validations
  validates :sig, :record_count, :override_count, presence: true
  validates :sig, length: {is: 4}
end
