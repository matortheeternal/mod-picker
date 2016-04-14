class Plugin < ActiveRecord::Base
  after_create :increment_counter_caches
  before_destroy :decrement_counter_caches

  belongs_to :mod_version, :inverse_of => 'plugins'

  # master associations
  has_many :dummy_masters, :inverse_of => 'plugin'
  has_many :masters, :inverse_of => 'plugin'
  has_many :children, :class_name => 'Master', :inverse_of => 'master_plugin'

  # plugin contents
  has_many :record_groups, :class_name => 'PluginRecordGroup', :inverse_of => 'plugin'
  has_many :overrides, :class_name => 'OverrideRecord', :inverse_of => 'plugin'
  has_many :plugin_errors, :inverse_of => 'plugin'

  # mod list usage
  has_many :mod_list_plugins, :inverse_of => 'plugin'
  has_many :mod_lists, :through => 'mod_list_plugins', :inverse_of => 'plugins'

  # is a compatibility plugin for
  has_many :compatibility_note_plugins, :foreign_key => 'compatibility_plugin_id', :inverse_of => 'compatibility_plugin'

  # load order notes
  has_many :load_before_notes, :foreign_key => 'load_first', :class_name => 'LoadOrderNote', :inverse_of => 'load_second_plugin'
  has_many :load_after_notes, :foreign_key => 'load_second', :class_name => 'LoadOrderNote', :inverse_of => 'load_second_plugin'

  # validations
  validates :mod_version_id, :filename, :crc_hash, presence: true
  validates :filename, length: {in: 1..64}
  validates :author, length: {in: 0..64}
  validates :description, length: {in: 0..512}
  validates :crc_hash, length: {in: 1..8}

  accepts_nested_attributes_for :dummy_masters, :masters, :record_groups, :overrides, :plugin_errors

  # Private methods
  private
    # counter caches
    def increment_counter_caches
      # puts "AWEFWAFWFAWEFAEWFAW==="
      # puts self.mod_list_plugins
      # self.mod_lists.plugins_count += 1
      # self.mod_lists.save
    end

    def decrement_counter_caches
      self.mod_lists.plugins_count -= 1
      self.mod_lists.save
    end

end
