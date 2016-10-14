class Plugin < ActiveRecord::Base
  include Filterable, Sortable, RecordEnhancements, ScopeHelpers

  # ATTRIBUTES
  attr_writer :master_plugins
  self.per_page = 100

  # SCOPES
  game_scope
  ids_scope :mod_option_id
  search_scope :filename, :alias => :search
  search_scope :author, :description
  range_scope :record_count, :alias => 'records'
  range_scope :override_count, :alias => 'overrides'
  counter_scope :errors_count, :mod_lists_count, :load_order_notes_count
  bytes_scope :file_size


  # UNIQUE SCOPES
  scope :visible, -> { eager_load(:mod).where(:mods => {hidden: false}) }
  scope :mods, -> (mod_ids) { includes(:mod_option).references(:mod_option).where(:mod_options => { :mod_id => mod_ids }) }
  scope :esm, -> { where("filename like '%.esm'") }
  scope :categories, -> (categories) { joins(:mod).where("mods.primary_category_id IN (:ids) OR mods.secondary_category_id IN (:ids)", ids: categories) }

  # ASSOCIATIONS
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

  accepts_nested_attributes_for :plugin_record_groups, :overrides, :plugin_errors

  # VALIDATIONS
  validates :game_id, :mod_option_id, :filename, :crc_hash, :file_size, presence: true

  validates :filename, length: {maximum: 64}
  validates :author, length: {maximum: 128}
  validates :description, length: {maximum: 512}
  validates :crc_hash, length: {is: 8}

  validates_associated :plugin_record_groups, :plugin_errors, :overrides

  # callbacks
  after_create :create_associations, :update_lazy_counters, :convert_dummy_masters
  before_destroy :delete_associations

  def update_lazy_counters
    self.errors_count = plugin_errors.count
    save!
  end

  def update_counters
    self.mod_lists_count = mod_list_plugins.count
    self.load_order_notes_count = load_order_notes.count
    update_lazy_counters
  end

  def create_associations
    if @master_plugins
      @master_plugins.each_with_index do |master, index|
        master_plugin = Plugin.find_by(filename: master[:filename], crc_hash: master[:crc_hash])
        master_plugin = Plugin.find_by(filename: master[:filename]) if master_plugin.nil?
        if master_plugin.nil?
          dummy_masters.create(filename: master[:filename], index: index)
        else
          masters.create(master_plugin_id: master_plugin.id, index: index)
        end
      end
    end
  end

  def load_order_notes
    LoadOrderNote.where("first_plugin_id = :id OR second_plugin_id = :id", id: id)
  end

  def convert_dummy_masters
    DummyMaster.where(filename: filename).each do |dummy|
      Master.create!({
          master_plugin_id: id,
          plugin_id: dummy.plugin_id,
          index: dummy.index
      })
      dummy.delete
    end
  end

  def create_dummy_masters
    Master.where(master_plugin_id: id).each do |master|
      DummyMaster.create!({
          plugin_id: master.plugin_id,
          filename: filename,
          index: master.index
      })
    end
  end

  def switch_associations(new_plugin_id)
    load_order_notes.destroy_all
    CompatibilityNote.where(compatibility_plugin_id: id).destroy_all
    ModListPlugin.where(plugin_id: id).destroy_all
  end

  def delete_associations
    OverrideRecord.where(plugin_id: id).delete_all
    PluginError.where(plugin_id: id).delete_all
    PluginRecordGroup.where(plugin_id: id).delete_all
    DummyMaster.where(plugin_id: id).delete_all
    create_dummy_masters
    Master.where(plugin_id: id).delete_all
    Master.where(master_plugin_id: id).delete_all
    ModListPlugin.where(plugin_id: id).destroy_all
  end

  def map_associations(plugin_id)
    OverrideRecord.where(plugin_id: id).update_all(plugin_id: plugin_id)
    PluginError.where(plugin_id: id).update_all(plugin_id: plugin_id)
    PluginRecordGroup.where(plugin_id: id).update_all(plugin_id: plugin_id)
    DummyMaster.where(plugin_id: id).update_all(plugin_id: plugin_id)
    Master.where(plugin_id: id).update_all(plugin_id: plugin_id)
    Master.where(master_plugin_id: id).update_all(master_plugin_id: plugin_id)
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
        :only => [:id, :filename, :errors_count],
        :include => {
            :mod => {
                :only => [:id, :name]
            },
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
          :only => [:id, :filename],
          :include => {
              :mod => {
                  :only => [:id, :name]
              }
          }
      }
      super(options.merge(default_options))
    else
      super(options)
    end
  end

  def self.sortable_columns
    {
        :except => [:game_id, :mod_option_id, :description],
        :include => {
            :mod => {
                :only => [:name]
            }
        }
    }
  end
end
