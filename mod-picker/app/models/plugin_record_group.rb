class PluginRecordGroup < ActiveRecord::Base
  self.primary_keys = :plugin_id, :sig

  belongs_to :plugin, :inverse_of => 'plugin_record_groups'

  # Validations
  validates :sig, :record_count, :override_count, presence: true
  validates :sig, length: {is: 4}
end
