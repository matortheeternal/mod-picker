class Plugin < ActiveRecord::Base
  belongs_to :mod_version, :inverse_of => 'plugins'

  has_many :record_groups, :class_name => 'PluginRecordGroup', :inverse_of => 'plugin'
  has_many :overrides, :class_name => 'OverrideRecord', :inverse_of => 'plugin'

  has_many :mod_list_plugins, :inverse_of => 'plugin'
  has_many :mod_lists, :through => 'mod_list_plugins', :inverse_of => 'plugins'

  has_many :compatibility_note_plugins, :foreign_key => 'compatibility_plugin_id', :inverse_of => 'compatibility_plugin'

  validates :mod_version_id, :filename, :crc_hash, presence: true
  validates :filename, length: {in: 1..64}
  validates :author, length: {in: 0..64}
  validates :description, length: {in: 0..512} do
    
  end
end
