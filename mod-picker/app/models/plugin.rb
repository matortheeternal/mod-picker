class Plugin < ActiveRecord::Base
  include Filterable, Sortable, RecordEnhancements

  attr_writer :master_plugins

  # GENERAL SCOPES
  scope :game, -> (game) { where(game_id: game) }
  scope :mod_options, -> (mod_option_ids) { where(mod_option_id: mod_option_ids) }
  scope :esm, -> { where("filename like '%.esm'") }
  # SEARCH SCOPES
  scope :search, -> (search) { where("filename like ?", "%#{search}%") }
  scope :author, -> (search) { where("author like ?", "%#{search}%") }
  scope :description, -> (search) { where("description like ?", "%#{search}%") }
  # HASH SCOPES
  scope :categories, -> (categories) { joins(:mod).where("mods.primary_category_id IN (?) OR mods.secondary_category_id IN (?)", categories, categories) }
  # STATISTIC SCOPES
  scope :file_size, -> (range) { where(file_size: (parseBytes(range[:min])..parseBytes(range[:max]))) }
  scope :records, -> (range) { where(record_count: (range[:min]..range[:max])) }
  scope :overrides, -> (range) { where(override_count: (range[:min]..range[:max])) }
  scope :errors, -> (range) { where(errors_count: (range[:min]..range[:max])) }
  scope :mod_lists, -> (range) { where(mod_lists_count: (range[:min]..range[:max])) }
  scope :load_order_notes, -> (range) { where(load_order_notes_count: (range[:min]..range[:max])) }

  # Associations
  belongs_to :game, :inverse_of => 'plugins'
  belongs_to :mod_option, :inverse_of => 'plugins'
  has_one :mod, :through => 'mod_option', :inverse_of => 'plugins'

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
  has_many :mod_lists, :through => 'mod_list_plugins'

  # is a compatibility plugin for
  has_many :compatibility_notes, :foreign_key => 'compatibility_plugin_id', :inverse_of => 'compatibility_plugin'

  # load order notes
  has_many :first_load_order_notes, :foreign_key => 'first_plugin_id', :class_name => 'LoadOrderNote', :inverse_of => 'second_plugin'
  has_many :second_load_order_notes, :foreign_key => 'second_plugin_id', :class_name => 'LoadOrderNote', :inverse_of => 'first_plugin'

  accepts_nested_attributes_for :plugin_record_groups, :overrides, :plugin_errors

  # numbers of plugins per page on the plugins index
  self.per_page = 100

  # validations
  validates :game_id, :mod_id, :filename, :crc_hash, :file_size, presence: true

  validates :filename, length: {maximum: 64}
  validates :author, length: {maximum: 128}
  validates :description, length: {maximum: 512}
  validates :crc_hash, length: {is: 8}

  validates_associated :plugin_record_groups, :plugin_errors, :overrides

  # callbacks
  after_create :create_associations, :update_lazy_counters
  before_destroy :delete_associations

  def update_lazy_counters
    self.errors_count = self.plugin_errors.count
  end

  def create_associations
    if @master_plugins
      @master_plugins.each_with_index do |master, index|
        master_plugin = Plugin.find_by(filename: master[:filename], crc_hash: master[:crc_hash])
        master_plugin = Plugin.find_by(filename: master[:filename]) if master_plugin.nil?
        if master_plugin.nil?
          self.dummy_masters.create(filename: master[:filename], index: index)
        else
          self.masters.create(master_plugin_id: master_plugin.id, index: index)
        end
      end
    end
  end

  def delete_associations
    OverrideRecord.where(plugin_id: self.id).delete_all
    PluginError.where(plugin_id: self.id).delete_all
    PluginRecordGroup.where(plugin_id: self.id).delete_all
    DummyMaster.where(plugin_id: self.id).delete_all
    Master.where(plugin_id: self.id).delete_all
    LoadOrderNote.where("first_plugin_id = ? OR second_plugin_id = ?", self.id, self.id).delete_all
    CompatibilityNote.where(compatibility_plugin_id: self.id).delete_all
    ModListPlugin.where(plugin_id: self.id).delete_all
  end

  def formatted_overrides
    output = {}
    self.overrides.each do |ovr|
      if output.has_key?(ovr.sig)
        output[ovr.sig].push(ovr.fid)
      else
        output[ovr.sig] = [ovr.fid]
      end
    end
    output
  end

  def self.index_json(collection)
    collection.as_json({
        :include => {
            :masters => {
                :except => [:plugin_id],
                :include => {
                    :master_plugin => {
                        :only => [:id, :mod_id, :filename]
                    }
                }
            },
            :mod => {
                :only => [:id, :name]
            }
        }
    })
  end

  def self.analysis_json(collection)
    collection.as_json({
        :only => [:id, :mod_id, :filename, :errors_count],
        :include => {
            :masters => {
                :except => [:plugin_id],
                :include => {
                    :master_plugin => {
                        :only => [:mod_id, :filename]
                    }
                }
            },
            :dummy_masters => {
                :except => [:plugin_id]
            }
        },
        :methods => :formatted_overrides
    })
  end

  def self.show_json(collection)
    collection.as_json({
        :include => {
            :masters => {
                :except => [:plugin_id],
                :include => {
                    :master_plugin => {
                        :only => [:mod_id, :filename]
                    }
                }
            },
            :dummy_masters => {
                :except => [:plugin_id]
            },
            :plugin_errors => {
                :except => [:plugin_id]
            },
            :plugin_record_groups => {
                :except => [:plugin_id]
            }
        },
        :methods => :formatted_overrides
    })
  end

  def as_json(options={})
    if JsonHelpers.json_options_empty(options)
      default_options = {
          :only => [:mod_id, :id, :filename],
          :include => {
              :mod => {
                  :only => [:name]
              }
          }
      }
      super(options.merge(default_options))
    else
      super(options)
    end
  end
end
