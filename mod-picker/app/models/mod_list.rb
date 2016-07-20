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

  # Groups to be used for organizing mods and plugins
  has_many :mod_list_groups, :inverse_of => 'mod_list'

  # INSTALL ORDER
  has_many :mod_list_mods, :inverse_of => 'mod_list'
  has_many :mods, :through => 'mod_list_mods', :inverse_of => 'mod_lists'

  # LOAD ORDER
  has_many :plugins, :through => 'mods'
  has_many :mod_list_plugins, :inverse_of => 'mod_list'
  has_many :custom_plugins, :class_name => 'ModListCustomPlugin', :inverse_of => 'mod_list'

  # ASSOCIATED NOTES
  has_many :mod_list_compatibility_notes, :inverse_of => 'mod_list'
  has_many :mod_list_install_order_notes, :inverse_of => 'mod_list'
  has_many :mod_list_load_order_notes, :inverse_of => 'mod_list'

  # CONFIG FILES
  has_many :mod_list_config_files, :inverse_of => 'mod_list'
  has_many :mod_list_custom_config_files, :inverse_of => 'mod_list'

  # TAGS
  has_many :mod_list_tags, :inverse_of => 'mod_list'
  has_many :tags, :through => 'mod_list_tags', :inverse_of => 'mod_lists'

  # ASSOCIATIONS FROM OTHER USERS
  has_many :mod_list_stars, :inverse_of => 'mod_list'
  has_many :comments, :as => 'commentable'

  # NESTED ATTRIBUTES
  accepts_nested_attributes_for :mod_list_groups, allow_destroy: true
  accepts_nested_attributes_for :mod_list_mods, allow_destroy: true
  accepts_nested_attributes_for :mod_list_plugins, allow_destroy: true
  accepts_nested_attributes_for :custom_plugins, allow_destroy: true
  accepts_nested_attributes_for :mod_list_config_files, allow_destroy: true
  accepts_nested_attributes_for :mod_list_custom_config_files, allow_destroy: true
  accepts_nested_attributes_for :mod_list_compatibility_notes, allow_destroy: true
  accepts_nested_attributes_for :mod_list_install_order_notes, allow_destroy: true
  accepts_nested_attributes_for :mod_list_load_order_notes, allow_destroy: true

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
    self.active_plugins_count = self.mod_list_plugins.where(active: true).count
    self.compatibility_notes_count = self.mod_list_compatibility_notes.all.count
    self.install_order_notes_count = self.mod_list_install_order_notes.all.count
    self.load_order_notes_count = self.mod_list_load_order_notes.all.count
    self.save_counters([:plugins_count, :active_plugins_count, :compatibility_notes_count, :install_order_notes_count, :load_order_notes_count])
  end

  def refresh_compatibility_notes
    mod_ids = mod_list_mods.all.ids
    cnote_ids = CompatibilityNote.where("first_mod_id in ? AND second_mod_id in ?", mod_ids, mod_ids).ids
    # delete compatibility notes that are no longer relevant
    cnotes = self.mod_list_compatibility_notes.all
    cnotes.each do |c|
      if cnote_ids.exclude?(c.compatibility_note_id)
        c.delete
      end
    end
    # add new compatibility notes
    current_cnote_ids = cnotes.ids
    cnote_ids.each do |id|
      if current_cnote_ids.exclude?(id)
        self.mod_list_compatibility_notes.create(compatibility_note_id: id)
      end
    end
  end

  def refresh_install_order_notes
    mod_ids = mod_list_mods.all.ids
    inote_ids = InstallOrderNote.where("first_mod_id in ? AND second_mod_id in ?", mod_ids, mod_ids).ids
    # delete install order notes that are no longer relevant
    inotes = self.mod_list_install_order_notes.all
    inotes.each do |n|
      if inote_ids.exclude?(n.install_order_note_id)
        n.delete
      end
    end
    # add new install order notes
    current_inote_ids = inotes.ids
    inote_ids.each do |id|
      if current_inote_ids.exclude?(id)
        self.mod_list_install_order_notes.create(install_order_note_id: id)
      end
    end
  end

  def refresh_load_order_notes
    plugin_ids = plugins.all.ids
    lnote_ids = LoadOrderNote.where("first_plugin_id in ? AND second_plugin_id in ?", plugin_ids, plugin_ids).ids
    # delete load order notes that are no longer relevant
    lnotes = self.mod_list_load_order_notes.all
    lnotes.each do |n|
      if lnote_ids.exclude?(n.load_order_note_id)
        n.delete
      end
    end
    # add new load order notes
    current_lnote_ids = lnotes.ids
    lnote_ids.each do |id|
      if current_lnote_ids.exclude?(id)
        self.mod_list_load_order_notes.create(load_order_note_id: id)
      end
    end
  end

  def incompatible_mods
    mod_ids = mod_list_mods.all.pluck(:mod_id)
    if mod_ids.empty?
      return []
    end

    # get incompatible notes
    incompatible_notes = CompatibilityNote.where("status in (?) AND (first_mod_id in (?) OR second_mod_id in (?))", [1, 2], mod_ids, mod_ids).pluck(:first_mod_id, :second_mod_id)
    incompatible_notes.flatten(1).uniq
  end

  def mod_tools
    mod_list_tools = @mod_list.mod_list_mods.joins(:mod).where(:mods => { is_utility: true })
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
