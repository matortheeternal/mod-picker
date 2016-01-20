class Master < ActiveRecord::Base
  belongs_to :plugin

  has_many :overrides, :class_name => 'PluginOverride', :inverse_of => 'master'
end
