class ModOptionPlugin < ActiveRecord::Base
  belongs_to :mod_option, :inverse_of => 'mod_option_plugins'
  belongs_to :plugin, :inverse_of => 'mod_option_plugins'
end