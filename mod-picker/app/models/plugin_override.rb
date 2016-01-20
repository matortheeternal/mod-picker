class PluginOverride < ActiveRecord::Base
  belongs_to :plugin, :inverse_of => 'overrides'
  belongs_to :master, :inverse_of => 'overrides'
end
