class ModList < ActiveRecord::Base
  include Filterable, Sortable, RecordEnhancements, CounterCache, Reportable, ScopeHelpers, Trackable, BetterJson, Dateable

  # ATTRIBUTES
  enum status: [ :under_construction, :testing, :complete ]
  enum visibility: [ :visibility_private, :visibility_unlisted, :visibility_public ]
  attr_accessor :updated_by
  self.per_page = 100

  # DATE COLUMNS
  date_column :submitted, :updated
  date_column :completed, conditional: "set_completed?"

  # EVENT TRACKING
  track :added, :updated, :hidden, :status
  track_milestones :column => 'stars_count', :milestones => [10, 50, 100, 500, 1000, 5000, 10000, 50000, 100000, 500000]

  # NOTIFICATION SUBSCRIPTIONS
  subscribe :submitter, to: [:updated, :hidden, :unhidden, *Event.milestones]
  subscribe :user_stars, to: [:status]

  # SCOPES
  hash_scope :hidden, alias: 'hidden'
  hash_scope :adult, alias: 'adult', column: 'has_adult_content'
  game_scope
  search_scope :name, :alias => 'search'
  search_scope :description
  user_scope :submitter
  enum_scope :status
  counter_scope :tools_count, :mods_count, :custom_tools_count, :custom_mods_count, :plugins_count, :master_plugins_count, :available_plugins_count, :custom_plugins_count, :config_files_count, :custom_config_files_count, :compatibility_notes_count, :install_order_notes_count, :load_order_notes_count, :ignored_notes_count, :bsa_files_count, :asset_files_count, :records_count, :override_records_count, :plugin_errors_count, :tags_count, :stars_count, :comments_count
  date_scope :submitted, :completed, :updated
  relational_division_scope :tags, :text, [
      { class_name: 'ModListTag', join_on: :mod_list_id, joinable_on: :tag_id },
      { class_name: 'Tag', join_on: :id }
  ]

  # UNIQUE SCOPES
  scope :visible, -> { where(hidden: false, visibility: 2) }
  scope :kind, -> (kinds) {
    # build is_collection values array
    is_collection = []
    is_collection.push(false) if kinds[:normal]
    is_collection.push(true) if kinds[:collection]

    # return query if length is 1
    where(is_collection: is_collection) if is_collection.length == 1
  }

  # ASSOCIATIONS
  belongs_to :game, :inverse_of => 'mod_lists'
  belongs_to :submitter, :class_name => 'User', :foreign_key => 'submitted_by', :inverse_of => 'mod_lists'

  # LOAD ORDER
  has_many :mod_list_plugins, :inverse_of => 'mod_list', :dependent => :destroy
  has_many :custom_plugins, :class_name => 'ModListCustomPlugin', :inverse_of => 'mod_list', :dependent => :destroy
  has_many :plugins, :through => 'mod_list_plugins'

  # INSTALL ORDER
  has_many :mod_list_mods, :inverse_of => 'mod_list', :dependent => :destroy
  has_many :mods, :through => 'mod_list_mods', :inverse_of => 'mod_lists'
  has_many :mod_list_mod_options, :through => 'mod_list_mods', :dependent => :destroy
  has_many :custom_mods, :class_name => 'ModListCustomMod', :inverse_of => 'mod_list', :dependent => :destroy

  # IGNORED NOTES
  has_many :ignored_notes, :class_name => 'ModListIgnoredNote', :inverse_of => 'mod_list', :dependent => :destroy

  # GROUPS
  # NOTE: This association has to be after the mods_list_mods, mod_list_plugins,
  # and custom_plugins associations in order to yield correct behavior with
  # nested attributes in certain circumstances (specifically when mods have been
  # moved out of a group and the group has been deleted)
  has_many :mod_list_groups, :inverse_of => 'mod_list', :dependent => :destroy

  # CONFIG FILES
  has_many :config_files, :through => 'mods'
  has_many :mod_list_config_files, :inverse_of => 'mod_list', :dependent => :destroy
  has_many :custom_config_files, :class_name => 'ModListCustomConfigFile', :inverse_of => 'mod_list', :dependent => :destroy

  # TAGS
  has_many :mod_list_tags, :inverse_of => 'mod_list', :dependent => :destroy
  has_many :tags, :through => 'mod_list_tags', :inverse_of => 'mod_lists'

  # STARS
  has_many :stars, :class_name => 'ModListStar', :inverse_of => 'mod_list', :dependent => :destroy
  has_many :user_stars, :through => 'stars', :source => 'user', :class_name => 'User', :inverse_of => 'starred_mod_lists'

  # COMMENTS
  has_many :comments, -> { where(parent_id: nil) }, :as => 'commentable', :dependent => :destroy

  # NESTED ATTRIBUTES
  accepts_nested_attributes_for :mod_list_mods, allow_destroy: true
  accepts_nested_attributes_for :custom_mods, allow_destroy: true
  accepts_nested_attributes_for :mod_list_plugins, allow_destroy: true
  accepts_nested_attributes_for :custom_plugins, allow_destroy: true
  accepts_nested_attributes_for :mod_list_groups, allow_destroy: true
  accepts_nested_attributes_for :mod_list_config_files, allow_destroy: true
  accepts_nested_attributes_for :custom_config_files, allow_destroy: true
  accepts_nested_attributes_for :ignored_notes, allow_destroy: true

  # COUNTER CACHE
  counter_cache_on :submitter
  bool_counter_cache :mod_list_mods, :is_utility, { true => :tools, false => :mods }
  bool_counter_cache :custom_mods, :is_utility, { true => :custom_tools, false => :custom_mods }
  counter_cache :mod_list_config_files, column: 'config_files_count'
  counter_cache :mod_list_plugins, column: 'plugins_count'
  counter_cache :custom_plugins, :custom_config_files, :ignored_notes, :stars
  counter_cache :mod_list_tags, column: 'tags_count'
  counter_cache :comments, conditional: { commentable_type: 'ModList' }

  # VALIDATIONS
  validates :game_id, :submitted_by, :name, presence: true

  validates_inclusion_of :is_collection, :hidden, :has_adult_content, {
    in: [true, false],
    message: "must be true or false"
  }

  validates :name, length: { in: 4..255 }
  validates :description, length: { maximum: 65535 }
  validates :name, length: { maximum: 255 }

  # CALLBACKS
  before_update :hide_comments, :unset_active_if_hidden
  before_destroy :unset_active

  def update_all_counters!
    reset_counters(:tools, :mods, :custom_tools, :custom_mods, :mod_list_plugins, :custom_plugins, :mod_list_config_files, :custom_config_files, :ignored_notes, :tags, :stars, :comments)
    update_lazy_counters
    save_columns!
  end

  def update_lazy_counters!
    update_lazy_counters
    save_columns!
  end

  def update_lazy_counters
    mod_ids = mod_list_mod_ids
    mod_option_ids = mod_list_mod_option_ids
    plugin_ids = mod_list_plugin_ids
    self.available_plugins_count = plugins_store.count
    self.master_plugins_count = Plugin.where(id: plugin_ids).esm.count
    self.compatibility_notes_count = CompatibilityNote.visible.mods(mod_ids).count
    self.install_order_notes_count = InstallOrderNote.visible.mods(mod_ids).count
    self.load_order_notes_count = LoadOrderNote.visible.plugins(plugin_ids).count

    plugin_ids = mod_list_plugins.official(false).pluck(:plugin_id)
    self.bsa_files_count = ModAssetFile.mod_options(mod_option_ids).bsa.count
    self.asset_files_count = ModAssetFile.mod_options(mod_option_ids).count
    self.records_count = Plugin.where(id: plugin_ids).sum(:record_count)
    self.override_records_count = Plugin.where(id: plugin_ids).sum(:override_count)
    self.plugin_errors_count = PluginError.plugins(plugin_ids).count
  end

  def custom_mod_params(mod, index)
    params = { name: mod[:name], index: index }
    params[:url] = NexusHelper.mod_url(game.nexus_name, mod[:nexus_info_id]) if mod.has_key?(:nexus_info_id)
    params
  end

  def import_mod(mod, index)
    if mod.has_key?(:id)
      mod_list_mods.create(mod_id: mod[:id], index: index)
    else
      custom_mods.create(custom_mod_params(mod, index))
    end
  end

  def import_mods(mods)
    mods.each_with_index { |mod, index| import_mod(mod, index + 1) }
  end

  def import_plugin(plugin, index)
    if plugin.has_key?(:id)
      mod_list_plugins.create(plugin_id: plugin[:id], index: index)
    else
      custom_plugins.create(filename: plugin[:filename], index: index)
    end
  end

  def import_plugins(plugins)
    plugins.each_with_index { |plugin, index| import_plugin(plugin, index) }
  end

  def clear_items
    mod_list_mods.destroy_all
    custom_mods.destroy_all
    mod_list_plugins.destroy_all
    custom_plugins.destroy_all
  end

  def import(import_params)
    clear_items
    import_mods(import_params[:mods])
    import_plugins(import_params[:plugins])
  end

  def hide_comments
    if attribute_changed?(:hidden) && hidden
      comments.update_all(:hidden => true)
    elsif self.attribute_changed?(:disable_comments) && disable_comments
      comments.update_all(:hidden => true)
    end
  end

  def add_official_content
    official_content = Mod.game(game_id).where(is_official: true)
    official_content.each_with_index do |m, index|
      mod_list_mod = ModListMod.new(mod_list_id: id, mod_id: m.id, index: index + 1)
      mod_list_mod.save!
      mod_list_mod.add_default_mod_options
    end
  end

  def conflicting_assets
    mod_option_ids = mod_list_mod_options.utility(false).official(false).pluck(:mod_option_id)
    ModAssetFile.conflicting(mod_option_ids).eager_load(:asset_file)
  end

  def self.update_adult(ids)
    ModList.where(id: ids).update_all("mod_lists.has_adult_content = false")
    ModList.where(id: ids).joins(:mods).where(:mods => {has_adult_content: true}).update_all("mod_lists.has_adult_content = true")
    Comment.commentables("ModList", ids).joins("INNER JOIN mod_lists ON mod_lists.id = comments.commentable_id").update_all("comments.has_adult_content = mod_lists.has_adult_content")
  end

  def set_active
    ActiveModList.clear(game_id, submitted_by)
    ActiveModList.create(game_id: game_id, user_id: submitted_by, mod_list_id: id)
  end

  def mod_list_plugin_ids
    mod_list_plugins.all.pluck(:plugin_id)
  end

  def mod_list_mod_ids
    mod_list_mods.all.pluck(:mod_id)
  end

  def mod_list_mod_option_ids
    mod_list_mod_options.all.pluck(:mod_option_id)
  end

  def plugins_store
    mod_option_ids = mod_list_mod_option_ids
    return Plugin.none if mod_option_ids.empty?
    
    Plugin.mod_options(mod_option_ids).includes(:mod)
  end

  def mod_compatibility_notes
    mod_ids = mod_list_mod_ids
    return CompatibilityNote.none if mod_ids.empty?

    CompatibilityNote.visible.mods(mod_ids).status([0, 1, 2]).includes(:first_mod, :second_mod, :submitter => :reputation)
  end

  def plugin_compatibility_notes
    mod_ids = mod_list_mod_ids
    return CompatibilityNote.none if mod_ids.empty?

    CompatibilityNote.visible.mods(mod_ids).status([3, 4]).includes(:first_mod, :second_mod, :history_entries, :submitter => :reputation)
  end

  def install_order_notes
    mod_ids = mod_list_mod_ids
    return InstallOrderNote.none if mod_ids.empty?

    InstallOrderNote.visible.mods(mod_ids).includes(:first_mod, :second_mod, :history_entries, :submitter => :reputation)
  end

    def load_order_notes
    plugin_ids = Plugin.mod_options(mod_list_mod_option_ids).ids
    return LoadOrderNote.none if plugin_ids.empty?

    LoadOrderNote.visible.plugins(plugin_ids).includes(:first_plugin, :second_plugin, :first_mod, :second_mod, :history_entries, :submitter => :reputation)
  end

  def required_tools
    mod_ids = mod_list_mod_ids
    return ModRequirement.none if mod_ids.empty?

    ModRequirement.utility(true).mods(mod_ids).visible.order(:required_id)
  end

  def required_mods
    mod_ids = mod_list_mod_ids
    return ModRequirement.none if mod_ids.empty?

    ModRequirement.utility(false).mods(mod_ids).visible.order(:required_id)
  end

  def required_plugins
    plugin_ids = mod_list_plugin_ids
    return Master.none if plugin_ids.empty?
    Master.eager_load(:plugin => :mod, :master_plugin => :mod).plugins(plugin_ids).visible.order(:master_plugin_id)
  end

  def incompatible_mod_ids
    mod_ids = mod_list_mod_ids
    return [] if mod_ids.empty?

    # get incompatible mod ids
    incompatible_ids = CompatibilityNote.visible.status([0, 1]).mod(mod_ids).pluck(:first_mod_id, :second_mod_id)
    # return array of unique mod ids from the notes, excluding mod list mod ids
    incompatible_ids.flatten(1).uniq - mod_ids
  end

  def asset_files
    mod_option_ids = mod_list_mod_option_ids
    return ModAssetFile.none if mod_option_ids.empty?

    ModAssetFile.mod_options(mod_option_ids).includes(:asset_file)
  end

  def override_records
    plugin_ids = mod_list_plugin_ids
    return OverrideRecord.none if plugin_ids.empty?

    OverrideRecord.plugins(plugin_ids)
  end

  def record_groups
    plugin_ids = mod_list_plugin_ids
    return PluginRecordGroup.none if plugin_ids.empty?

    PluginRecordGroup.plugins(plugin_ids)
  end

  def plugin_errors
    plugin_ids = mod_list_plugin_ids
    return PluginError.none if plugin_ids.empty?

    PluginError.plugins(plugin_ids)
  end

  def base_text
    "# This file was automatically generated by Mod Picker\r\n"
  end

  def modlist_text
    mods = mod_list_mods.utility(false).official(false).includes(:mod).order(:index => :DESC)
    mods.reduce(base_text) { |text, mod_list_mod| "#{text}+#{mod_list_mod.mod.name}\r\n" }
  end

  def plugins_text
    plugins = mod_list_plugins.includes(:plugin).order(:index)
    plugins.reduce(base_text) { |text, mod_list_plugin| "#{text}#{mod_list_plugin.plugin.filename}\r\n" }
  end

  def links_text
    tools = mod_list_mods.utility(true).official(false).preload(:mod => [:lover_infos, :workshop_infos, :custom_sources, :nexus_infos => :game]).order(:index)
    mods = mod_list_mods.utility(false).official(false).preload(:mod => [:lover_infos, :workshop_infos, :custom_sources, :nexus_infos => :game]).order(:index)
    a = [base_text, "\r\nTools:"]
    tools.each { |mod_list_tool| a.push(mod_list_tool.mod.links_text) }
    a.push("\r\nMods:")
    mods.each { |mod_list_mod| a.push(mod_list_mod.mod.links_text) }
    a.join("\r\n")
  end

  def set_completed?
    status == "complete" && completed.nil?
  end

  def compact_plugins
    mod_list_plugins.order(:index).each_with_index do |p, i|
      if p.index != i
        p.index = i
        p.save!
      end
    end
  end

  private
    def unset_active_if_hidden
      unset_active if attribute_changed?(:hidden) && hidden
    end

    def unset_active
      ActiveModList.where(user_id: submitted_by, mod_list_id: id).destroy_all
    end
end
