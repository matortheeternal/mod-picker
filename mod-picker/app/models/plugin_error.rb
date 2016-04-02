class PluginError < ActiveRecord::Base
  belongs_to :plugin, :inverse_of => 'errors'
end
