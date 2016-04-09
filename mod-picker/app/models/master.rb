class Master < ActiveRecord::Base
  self.primary_keys = :plugin_id, :master_plugin_id

  belongs_to :plugin, :inverse_of => 'plugins_masters'
  belongs_to :master_plugin, :class_name => 'Plugin', :foreign_key => 'master_plugin_id', :inverse_of => 'masters_plugins'

  validates :plugin_id, :master_plugin_id, :index, presence: true
end
