class Plugin < ActiveRecord::Base
  include Filterable, Sortable, CounterCacheEnhancements

  attr_writer :master_filenames

  scope :search, -> (search) { where("filename like ?", "%#{search}%") }
  scope :game, -> (game) { where(game_id: game) }

  belongs_to :game, :inverse_of => 'plugins'
  belongs_to :mod, :inverse_of => 'plugins'

  # master associations
  has_many :dummy_masters, :inverse_of => 'plugin', :dependent => :destroy
  has_many :masters, :inverse_of => 'plugin', :dependent => :destroy
  has_many :children, :class_name => 'Master', :inverse_of => 'master_plugin', :dependent => :destroy

  # plugin contents
  has_many :plugin_record_groups, :inverse_of => 'plugin', :dependent => :destroy
  has_many :overrides, :class_name => 'OverrideRecord', :inverse_of => 'plugin', :dependent => :destroy
  has_many :plugin_errors, :inverse_of => 'plugin', :dependent => :destroy

  # mod list usage
  has_many :mod_list_plugins, :inverse_of => 'plugin', :dependent => :destroy
  has_many :mod_lists, :through => 'mod_list_plugins', :inverse_of => 'plugins'

  # is a compatibility plugin for
  has_many :compatibility_note_plugins, :foreign_key => 'compatibility_plugin_id', :inverse_of => 'compatibility_plugin'

  # load order notes
  has_many :first_load_order_notes, :foreign_key => 'first_plugin_id', :class_name => 'LoadOrderNote', :inverse_of => 'load_second_plugin'
  has_many :second_load_order_notes, :foreign_key => 'second_plugin_id', :class_name => 'LoadOrderNote', :inverse_of => 'load_second_plugin'

  accepts_nested_attributes_for :plugin_record_groups, :overrides, :plugin_errors

  # validations
  validates :mod_id, :filename, :crc_hash, presence: true
  validates :filename, length: {in: 1..64}
  validates :author, length: {in: 0..64}
  validates :description, length: {in: 0..512}
  validates :crc_hash, length: {in: 1..8}

  # callbacks
  after_create :create_associations

  def create_masters
    @master_filenames.each_with_index do |master_filename, index|
      master_plugin = Plugin.find_by(filename: master_filename)
      if master_plugin.nil?
        self.dummy_masters.create(filename: master_filename, index: index)
      else
        self.masters.create(master_plugin_id: master_plugin.id, index: index)
      end
    end
  end

  def create_associations
    self.create_masters
    self.save!
  end

  def self.as_json(options={})
    if JsonHelpers.json_options_empty(options)
      default_options = {
          :include => {
              :masters => {
                  :except => [:plugin_id]
              },
              :overrides => {
                  :except => [:plugin_id]
              },
              :plugin_errors => {
                  :except => [:plugin_id]
              },
              :plugin_record_groups => {
                  :except => [:plugin_id]
              }
          }
      }
      super(options.merge(default_options))
    else
      super(options)
    end
  end
end
