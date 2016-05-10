class Plugin < ActiveRecord::Base
  belongs_to :game, :inverse_of => 'plugins'
  belongs_to :mod, :inverse_of => 'plugins'

  # master associations
  has_many :dummy_masters, :inverse_of => 'plugin'
  has_many :masters, :inverse_of => 'plugin'
  has_many :children, :class_name => 'Master', :inverse_of => 'master_plugin'

  # plugin contents
  has_many :plugin_record_groups, :inverse_of => 'plugin'
  has_many :overrides, :class_name => 'OverrideRecord', :inverse_of => 'plugin'
  has_many :plugin_errors, :inverse_of => 'plugin'

  # mod list usage
  has_many :mod_list_plugins, :inverse_of => 'plugin'
  has_many :mod_lists, :through => 'mod_list_plugins', :inverse_of => 'plugins'

  # is a compatibility plugin for
  has_many :compatibility_note_plugins, :foreign_key => 'compatibility_plugin_id', :inverse_of => 'compatibility_plugin'

  # load order notes
  has_many :first_load_order_notes, :foreign_key => 'first_plugin_id', :class_name => 'LoadOrderNote', :inverse_of => 'load_second_plugin'
  has_many :second_load_order_notes, :foreign_key => 'second_plugin_id', :class_name => 'LoadOrderNote', :inverse_of => 'load_second_plugin'

  # validations
  validates :mod_id, :filename, :crc_hash, presence: true
  validates :filename, length: {in: 1..64}
  validates :author, length: {in: 0..64}
  validates :description, length: {in: 0..512}
  validates :crc_hash, length: {in: 1..8}

  accepts_nested_attributes_for :dummy_masters, :masters, :plugin_record_groups, :overrides, :plugin_errors
end
