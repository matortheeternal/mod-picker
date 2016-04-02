class PluginRecordGroup < ActiveRecord::Base
  self.primary_keys = :plugin_id, :sig

  belongs_to :plugin, :inverse_of => 'record_groups'
end
