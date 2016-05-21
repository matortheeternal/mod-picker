class Master < EnhancedRecord::Base
  self.primary_keys = :plugin_id, :master_plugin_id

  belongs_to :plugin, :inverse_of => 'masters'
  belongs_to :master_plugin, :class_name => 'Plugin', :foreign_key => 'master_plugin_id', :inverse_of => 'children'

  validates :plugin_id, :master_plugin_id, :index, presence: true
end
