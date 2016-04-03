class ModListPlugin < ActiveRecord::Base
  self.primary_keys = :mod_list_id, :plugin_id

  belongs_to :mod_list, :inverse_of => 'mod_list_plugins'
  belongs_to :plugin, :inverse_of => 'mod_list_plugins'
end
