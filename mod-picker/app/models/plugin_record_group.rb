class PluginRecordGroup < ActiveRecord::Base
  belongs_to :plugin, :inverse_of => 'record_groups'
end
