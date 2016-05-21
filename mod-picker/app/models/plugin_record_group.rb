class PluginRecordGroup < ActiveRecord::Base
  self.primary_keys = :plugin_id, :sig

  belongs_to :plugin, :inverse_of => 'plugin_record_groups'

  # Validations
  validates :plugin_id, :signature, :new_records, :override_records, presence: true
  validates :signature, length: {maximum: 4}
end
