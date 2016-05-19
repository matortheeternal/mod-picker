class PluginError < ActiveRecord::Base
  belongs_to :plugin, :inverse_of => 'plugin_errors'
end
