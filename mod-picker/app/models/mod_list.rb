class ModList < ActiveRecord::Base
  include Filterable, Sortable, RecordEnhancements, Reportable

  enum status: [ :under_construction, :testing, :complete ]
  enum visibility: [ :visibility_private, :visibility_unlisted, :visibility_public ]

  # BOOLEAN SCOPES
  scope :include_adult, -> (bool) { where(has_adult_content: false) if !bool }
  # GENERAL SCOPES
  scope :visible, -> { where(hidden: false, visibility: 2) }
  scope :game, -> (game_id) { where(game_id: game_id) }
  scope :status, -> (status) { where(status: status) }

  # ASSOCIATIONS
  belongs_to :game, :inverse_of => 'mod_lists'
  belongs_to :submitter, :class_name => 'User', :foreign_key => 'submitted_by', :inverse_of => 'mod_lists'

  # INSTALL ORDER
  has_many :mod_list_mods, :inverse_of => 'mod_list'
  has_many :mods, :through => 'mod_list_mods', :inverse_of => 'mod_lists'

  # LOAD ORDER
  has_many :plugins, :through => 'mods'
  has_many :mod_list_plugins, :inverse_of => 'mod_list'
  has_many :custom_plugins, :class_name => 'ModListCustomPlugin', :inverse_of => 'mod_list'

  # GROUPS
  # NOTE: This association has to be after the mods_list_mods, mod_list_plugins,
  # and custom_plugins associations in order to yield correct behavior with
  # nested attributes in certain circumstances (specifically when mods have been
  # moved out of a group and the group has been deleted)
  has_many :mod_list_groups, :inverse_of => 'mod_list'

  # CONFIG FILES
  has_many :mod_list_config_files, :inverse_of => 'mod_list'
  has_many :mod_list_custom_config_files, :inverse_of => 'mod_list'

  # TAGS
  has_many :mod_list_tags, :inverse_of => 'mod_list'
  has_many :tags, :through => 'mod_list_tags', :inverse_of => 'mod_lists'

  # ASSOCIATIONS FROM OTHER USERS
  has_many :mod_list_stars, :inverse_of => 'mod_list'
  has_many :comments, -> { where(parent_id: nil) }, :as => 'commentable'

  # NESTED ATTRIBUTES
  accepts_nested_attributes_for :mod_list_mods, allow_destroy: true
  accepts_nested_attributes_for :mod_list_plugins, allow_destroy: true
  accepts_nested_attributes_for :custom_plugins, allow_destroy: true
  accepts_nested_attributes_for :mod_list_groups, allow_destroy: true
  accepts_nested_attributes_for :mod_list_config_files, allow_destroy: true
  accepts_nested_attributes_for :mod_list_custom_config_files, allow_destroy: true

  # Validations
  validates :game_id, :submitted_by, :name, presence: true

  validates_inclusion_of :is_collection, :hidden, :has_adult_content, {
    in: [true, false],
    message: "must be true or false"
  }

  validates :name, length: { in: 4..255 }
  validates :description, length: { maximum: 65535 }
  validates :name, length: { maximum: 255 }

  # Callbacks
  after_create :increment_counters, :set_active
  before_save :set_dates
  before_destroy :decrement_counters, :unset_active

  def update_eager_counters
    self.mods_count = self.mods.where(is_utility: false).count
    self.tools_count = self.mods.where(is_utility: true).count
    self.save_counters([:mods_count, :tools_count])
  end

  def update_lazy_counters
    mod_ids = self.mods.ids
    self.plugins_count = Plugin.where(mod_id: mod_ids).count
    self.active_plugins_count = self.mod_list_plugins.count
    self.save_counters([:plugins_count, :active_plugins_count])
  end

  def mod_list_mod_ids
    mod_list_mods.all.pluck(:mod_id)
  end

  def mod_list_plugin_ids
    mod_ids = self.mod_list_mod_ids
    return [] if mod_ids.empty?

    Plugin.where(mod_id: mod_ids).ids
  end

  def mod_compatibility_notes
    mod_ids = self.mod_list_mod_ids
    return [] if mod_ids.empty?

    CompatibilityNote.visible.mods(mod_ids).status([0, 1, 2])
  end

  def plugin_compatibility_notes
    mod_ids = self.mod_list_mod_ids
    return [] if mod_ids.empty?

    CompatibilityNote.visible.mods(mod_ids).status([3, 4])
  end

  def install_order_notes
    mod_ids = self.mod_list_mod_ids
    return [] if mod_ids.empty?

    InstallOrderNote.visible.mods(mod_ids)
  end

  def load_order_notes
    plugin_ids = self.mod_list_plugin_ids
    return [] if plugin_ids.empty?

    LoadOrderNote.visible.plugins(plugin_ids)
  end

  def required_tools
    mod_ids = self.mod_list_mod_ids
    return [] if mod_ids.empty?

    ModRequirement.mods(mod_ids).utility(true)
  end

  def required_mods
    mod_ids = self.mod_list_mod_ids
    return [] if mod_ids.empty?

    ModRequirement.mods(mod_ids).utility(false).order(:required_id)
  end

  def required_plugins
    plugin_ids = self.mod_list_plugin_ids
    return [] if plugin_ids.empty?

    Master.plugins(plugin_ids).order(:master_plugin_id)
  end

  def incompatible_mods
    mod_ids = self.mod_list_mod_ids
    return [] if mod_ids.empty?

    # get incompatible mod ids
    incompatible_ids = CompatibilityNote.status([1, 2]).mod(mod_ids).pluck(:first_mod_id, :second_mod_id)
    # return array of unique mod ids from the notes, excluding mod list mod ids
    incompatible_ids.flatten(1).uniq - mod_ids
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
           }
        }
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
          :except => [:submitted_by],
          :include => {
              :submitter => {
                  :only => [:id, :username, :role, :title],
                  :include => {
                      :reputation => {:only => [:overall]}
                  },
                  :methods => :avatar
              },
          }
      }
      super(options.merge(default_options))
    else
      super(options)
    end
  end

  private
    def set_dates
      if self.submitted.nil?
        self.submitted = DateTime.now
      else
        self.edited = DateTime.now
      end
    end

    def increment_counters
      self.submitter.update_counter(:mod_lists_count, 1)
    end

    def decrement_counters
      self.submitter.update_counter(:mod_lists_count, -1)
    end

    def set_active
      self.submitter.active_mod_list_id = self.id
      self.submitter.save
    end

    def unset_active
      if self.submitter.active_mod_list_id == self.id
        self.submitter.active_mod_list_id = nil
        self.submitter.save
      end
    end
end
