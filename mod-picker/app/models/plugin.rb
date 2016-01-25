class Plugin < ActiveRecord::Base
  belongs_to :mod_version, :inverse_of => 'plugins'

  has_many :record_groups, :class_name => 'PluginRecordGroup', :inverse_of => 'plugin'
  has_many :overrides, :class_name => 'OverrideRecord', :inverse_of => 'plugin'

  has_many :mod_list_plugins, :inverse_of => 'plugin'
  has_many :mod_lists, :through => 'mod_list_plugins', :inverse_of => 'plugins'

  has_many :compatibility_notes, :foreign_key => 'compatibility_plugin_id', :inverse_of => 'compatibility_plugin'
end
