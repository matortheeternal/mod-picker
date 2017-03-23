class Plugin < ActiveRecord::Base
  include Filterable, Sortable, RecordEnhancements, CounterCache, ScopeHelpers, BetterJson

  # ATTRIBUTES
  attr_accessor :master_plugins
  self.per_page = 100

  # SCOPES
  game_scope
  hash_scope :approved, alias: 'approved', table: 'mods'
  hash_scope :hidden, alias: 'hidden', table: 'mods'
  hash_scope :adult, alias: 'adult', column: 'has_adult_content'
  ids_scope :mod_option_id
  search_scope :filename, :alias => :search
  search_scope :author, :description
  range_scope :record_count, :alias => 'records'
  range_scope :override_count, :alias => 'overrides'
  counter_scope :errors_count, :mod_lists_count, :load_order_notes_count
  bytes_scope :file_size

  # UNIQUE SCOPES
  scope :visible, -> { eager_load(:mod).where(:mods => {hidden: false}) }
  scope :mods, -> (mod_ids) { eager_load(:mod_option).where(:mod_options => { :mod_id => mod_ids }) }
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

  # notes
  has_many :compatibility_notes, :foreign_key => 'compatibility_plugin_id', :inverse_of => 'compatibility_plugin', :dependent => :destroy
  has_many :first_load_order_notes, :class_name => 'LoadOrderNote', :foreign_key => 'first_plugin_filename', :inverse_of => 'first_plugin', :primary_key => 'filename', :dependent => :destroy
  has_many :second_load_order_notes, :class_name => 'LoadOrderNote', :foreign_key => 'second_plugin_filename', :inverse_of => 'second_plugin', :primary_key => 'filename',  :dependent => :destroy

  accepts_nested_attributes_for :plugin_record_groups, :overrides, :plugin_errors

  # COUNTER CACHE
  counter_cache :mod_list_plugins, column: 'mod_lists_count'
  counter_cache :load_order_notes, conditional: { hidden: false, approved: true }, custom_reflection: { klass: LoadOrderNote, query_method: 'plugin_count_subquery' }

  # VALIDATIONS
  validates :game_id, :mod_option_id, :filename, :crc_hash, :file_size, presence: true

  validates :filename, length: {maximum: 256}
  validates :author, length: {maximum: 512}
  validates :description, length: {maximum: 512}
  validates :crc_hash, length: {is: 8}

  validates_associated :plugin_record_groups, :plugin_errors, :overrides

  # callbacks
  before_save :set_adult
  after_create :convert_dummy_masters
  after_save :create_associations, :update_lazy_counters
  before_update :clear_associations
  before_destroy :prepare_to_destroy

  def self.find_batch(batch, game)
    batch.collect do |item|
      Plugin.visible.game(game).where(filename: item[:plugin_filename]).first
    end
  end

  def self.find_master_plugin(game, master)
    Plugin.game(game).where(filename: master[:filename], crc_hash: master[:crc_hash]).first ||
        Plugin.game(game).where(filename: master[:filename]).first
  end

  def update_lazy_counters
    self.errors_count = plugin_errors.count
    update_column(:errors_count, errors_count)
  end

  def update_counters
    self.mod_lists_count = mod_list_plugins.count
    self.load_order_notes_count = load_order_notes.count
    update_lazy_counters
  end

  def create_associations
    if @master_plugins
      @master_plugins.each_with_index do |master, index|
        master_plugin = Plugin.find_master_plugin(game_id, master)
        if master_plugin.nil?
          dummy_masters.create(filename: master[:filename], index: index)
        else
          masters.create(master_plugin_id: master_plugin.id, index: index)
        end
      end
    end
  end

  def load_order_notes
    LoadOrderNote.where("first_plugin_filename = :filename OR second_plugin_filename = :filename", filename: filename)
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

  def clear_associations
    OverrideRecord.where(plugin_id: id).delete_all
    PluginError.where(plugin_id: id).delete_all
    PluginRecordGroup.where(plugin_id: id).delete_all
    DummyMaster.where(plugin_id: id).delete_all
    Master.where(plugin_id: id).delete_all
  end

  def prepare_to_destroy
    clear_associations
    create_dummy_masters
    Master.where(master_plugin_id: id).delete_all
    ModListPlugin.where(plugin_id: id).delete_all
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

  private
    def set_adult
      self.has_adult_content = mod.has_adult_content
      true
    end
end
