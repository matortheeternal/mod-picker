class ModList < ActiveRecord::Base
  include Filterable, Sortable, RecordEnhancements, Reportable, ScopeHelpers

  enum status: [ :under_construction, :testing, :complete ]
  enum visibility: [ :visibility_private, :visibility_unlisted, :visibility_public ]

  # SCOPES
  include_scope :has_adult_content, :alias => 'include_adult'
  game_scope
  search_scope :name, :alias => 'search'
  search_scope :description
  user_scope :submitter
  enum_scope :status
  counter_scope :tools_count, :mods_count, :custom_tools, :custom_mods, :plugins_count, :master_plugins_count, :available_plugins_count, :custom_plugins_count, :config_files_count, :custom_config_files_count, :compatibility_notes_count, :install_order_notes_count, :load_order_notes_count, :ignored_notes_count, :bsa_files_count, :asset_files_count, :records_count, :override_records_count, :plugin_errors_count, :tags_count, :stars_count, :comments_count
  date_scope :submitted, :completed, :updated

  # UNIQUE SCOPES
  scope :visible, -> { where(hidden: false, visibility: 2) }
  scope :tags, -> (array) { joins(:tags).where(:tags => {text: array}).having("COUNT(DISTINCT tags.text) = ?", array.length) }
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

  # ASSOCIATIONS FROM OTHER USERS
  has_many :mod_list_stars, :inverse_of => 'mod_list', :dependent => :destroy
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

  # numbers of mod lists per page on the mod lists index
  self.per_page = 100

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
  after_create :increment_counters
  before_update :hide_comments
  before_save :set_dates
  before_destroy :decrement_counters, :unset_active

  def update_all_counters
    self.tools_count = mod_list_mods.utility(true).count
    self.mods_count = mod_list_mods.utility(false).count
    self.custom_tools_count = custom_mods.utility(true).count
    self.custom_mods_count = custom_mods.utility(false).count
    self.plugins_count = mod_list_plugins.count
    self.custom_plugins_count = custom_plugins.count
    self.config_files_count = config_files.count
    self.custom_config_files_count = custom_config_files.count
    self.ignored_notes_count = ignored_notes.count
    self.tags_count = tags.count
    self.stars_count = mod_list_stars.count
    self.comments_count = comments.count

    save_counters([:tools_count, :mods_count, :custom_tools_count, :custom_mods_count, :plugins_count, :custom_plugins_count, :config_files_count, :custom_config_files_count, :ignored_notes_count, :tags_count, :stars_count, :comments_count])

    update_lazy_counters
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

    save_counters([:available_plugins_count, :master_plugins_count, :compatibility_notes_count, :install_order_notes_count, :load_order_notes_count, :bsa_files_count, :asset_files_count, :records_count, :override_records_count, :plugin_errors_count])
  end

  def hide_comments
    if attribute_changed?(:hidden) && hidden
      comments.update_all(:hidden => true)
    elsif self.attribute_changed?(:disable_comments) && disable_comments
      comments.update_all(:hidden => true)
    end
  end

  def add_official_content
    # official mods
    official_content = Mod.game(game_id).where(is_official: true)
    official_content.each_with_index do |m, index|
      mod_list_mods.create({
          mod_id: m.id,
          index: index
      })
    end

    # official plugins
    official_plugins = Plugin.mods(official_content)
    official_plugins.each_with_index do |p, index|
      mod_list_plugins.create({
          plugin_id: p.id,
          index: index
      })
    end
  end

  def set_active
    submitter.active_mod_list_id = id
    submitter.save
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

    Plugin.mod_options(mod_option_ids)
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

    LoadOrderNote.visible.plugins(plugin_ids).includes(:first_plugin, :second_plugin, :history_entries, :submitter => :reputation)
  end

  def required_tools
    mod_ids = mod_list_mod_ids
    return ModRequirement.none if mod_ids.empty?

    ModRequirement.mods(mod_ids).includes(:required_mod, :mod).utility(true)
  end

  def required_mods
    mod_ids = mod_list_mod_ids
    return ModRequirement.none if mod_ids.empty?

    ModRequirement.mods(mod_ids).utility(false).includes(:required_mod, :mod).order(:required_id)
  end

  def required_plugins
    plugin_ids = mod_list_plugin_ids
    return Master.none if plugin_ids.empty?

    Master.plugins(plugin_ids).includes(:plugin, :master_plugin).order(:master_plugin_id)
  end

  def incompatible_mods
    mod_ids = mod_list_mod_ids
    return [] if mod_ids.empty?

    # get incompatible mod ids
    incompatible_ids = CompatibilityNote.status([0, 1]).mod(mod_ids).pluck(:first_mod_id, :second_mod_id)
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

  def show_json
    self.as_json({
        :except => [:submitted_by],
        :include => {
            :submitter => {
                :only => [:id, :username, :role, :title],
                :include => {
                    :reputation => {:only => [:overall]}
                },
                :methods => :avatar
            },
            :tags => {
                :except => [:game_id, :hidden, :mods_count],
                :include => {
                    :submitter => {
                        :only => [:id, :username]
                    }
                }
            },
            :ignored_notes => {
                :except => [:mod_list_id]
            }
        }
    })
  end

  def tracking_json
    self.as_json({
        :only => [:id, :name, :mods_count, :plugins_count, :active_plugins_count, :custom_plugins_count],
        :methods => [:incompatible_mods, :mod_list_mod_ids]
    })
  end

  def self.home_json(collection)
    # TODO: Revise this as needed
    collection.as_json({
        :only => [:id, :name, :completed, :mods_count, :plugins_count],
        :include => {
            :submitter => {
                :only => [:id, :username, :role, :title],
                :include => {
                    :reputation => {:only => [:overall]}
                },
                :methods => :avatar
            }
        }
    })
  end

  def as_json(options={})
    if JsonHelpers.json_options_empty(options)
      default_options = {
          :except => [:game_id, :submitted_by],
          :include => {
              :submitter => {
                  :only => [:id, :username]
              }
          }
      }
      super(options.merge(default_options))
    else
      super(options)
    end
  end

  private
    def set_dates
      if submitted.nil?
        self.submitted = DateTime.now
      else
        self.updated = DateTime.now
      end
      if status == "complete" && completed.nil?
        self.completed = DateTime.now
      end
    end

    def increment_counters
      submitter.update_counter(:mod_lists_count, 1)
    end

    def decrement_counters
      submitter.update_counter(:mod_lists_count, -1)
    end

    def unset_active
      if submitter.active_mod_list_id == self.id
        submitter.active_mod_list_id = nil
        submitter.save
      end
    end
end
