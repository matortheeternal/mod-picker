class LoadOrderNote < ActiveRecord::Base
  include Filterable, Sortable, RecordEnhancements, Correctable, Helpfulable, Reportable, ScopeHelpers, Trackable

  # ATTRIBUTES
  self.per_page = 25

  # EVENT TRACKING
  track :added, :approved, :hidden
  track :message, :column => 'moderator_message'

  # NOTIFICATION SUBSCRIPTION
  subscribe :mod_author_users, to: [:added, :approved, :unhidden]
  subscribe :submitter, to: [:message, :approved, :unapproved, :hidden, :unhidden]

  # SCOPES
  include_scope :hidden
  include_scope :has_adult_content, :alias => 'include_adult'
  visible_scope :approvable => true
  game_scope
  search_scope :text_body, :alias => 'search'
  user_scope :submitter
  ids_scope :plugin_id, :columns => [:first_plugin_id, :second_plugin_id]
  date_scope :submitted, :edited

  # UNIQUE SCOPES
  scope :plugin_filename, -> (filename) { joins(:first_plugin, :second_plugin).where("plugins.filename like ?", "%#{filename}%") }

  # ASSOCIATIONS
  belongs_to :game, :inverse_of => 'load_order_notes'
  belongs_to :submitter, :class_name => 'User', :foreign_key => 'submitted_by', :inverse_of => 'load_order_notes'
  belongs_to :editor, :class_name => 'User', :foreign_key => 'edited_by'

  # plugins associatied with this load order note
  belongs_to :first_plugin, :foreign_key => 'first_plugin_id', :class_name => 'Plugin'
  belongs_to :second_plugin, :foreign_key => 'second_plugin_id', :class_name => 'Plugin'

  # mods associated with this load order note
  has_one :first_mod, :through => :first_plugin, :class_name => 'Mod', :source => 'mod', :foreign_key => 'mod_id'
  has_one :second_mod, :through => :second_plugin, :class_name => 'Mod', :source => 'mod', :foreign_key => 'mod_id'

  # mod lists this load order note is ignored on
  has_many :mod_list_ignored_notes, :as => 'note'

  # old versions of this load order note
  has_many :history_entries, :class_name => 'LoadOrderNoteHistoryEntry', :inverse_of => 'load_order_note', :foreign_key => 'load_order_note_id'
  has_many :editors, -> { uniq }, :class_name => 'User', :through => 'history_entries'

  # VALIDATIONS
  validates :game_id, :submitted_by, :first_plugin_id, :second_plugin_id, :text_body, presence: true

  validates :text_body, length: {in: 256..16384}
  validate :unique_plugins

  # CALLBACKS
  after_create :increment_counters
  before_save :set_dates
  before_destroy :decrement_counters

  def unique_plugins
    if first_plugin_id == second_plugin_id
      errors.add(:plugins, "You cannot create a Load Order Note between a plugin and itself.")
      return
    end

    plugin_ids = [first_plugin_id, second_plugin_id]
    note = LoadOrderNote.plugins(plugin_ids).where("hidden = 0 and id != ?", self.id).first
    if note.present?
      if note.approved
        errors.add(:plugins, "A Load Order Note for these plugins already exists.")
        errors.add(:link_id, note.id)
      else
        errors.add(:plugins, "An unapproved Load Order Note for these plugins already exists.")
      end
    end
  end

  def mods
    [first_mod, second_mod]
  end

  def mod_author_users
    User.includes(:mod_authors).where(:mod_authors => {mod_id: [first_mod.id, second_mod.id]})
  end

  def plugins
    [first_plugin, second_plugin]
  end

  def create_history_entry
    history_summary = edited_by.nil? ? "Load Order Note Created" : edit_summary
    history_entries.create(
        edited_by: edited_by || submitted_by,
        text_body: text_body,
        edit_summary: history_summary || "",
        edited: edited || submitted
    )
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
              :editor => {
                  :only => [:id, :username, :role]
              },
              :editors => {
                  :only => [:id, :username, :role]
              }
          },
          :methods => [:mods, :plugins]
      }
      super(options.merge(default_options))
    else
      super(options)
    end
  end

  def notification_json_options(event_type)
    {
        :only => [:submitted_by, (:moderator_message if event_type == :message)].compact,
        :methods => [:mods, :plugins]
    }
  end

  def self.sortable_columns
    {
        :except => [:game_id, :submitted_by, :edited_by, :corrector_id, :first_plugin_id, :second_plugin_id, :text_body, :edit_summary, :moderator_message],
        :include => {
            :submitter => {
                :only => [:username],
                :include => {
                    :reputation => {
                        :only => [:overall]
                    }
                }
            }
        }
    }
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
      self.first_mod.update_counter(:load_order_notes_count, 1)
      self.second_mod.update_counter(:load_order_notes_count, 1)
      self.submitter.update_counter(:load_order_notes_count, 1)
      self.first_plugin.update_counter(:load_order_notes_count, 1)
      self.second_plugin.update_counter(:load_order_notes_count, 1)
    end

    def decrement_counters
      self.first_mod.update_counter(:load_order_notes_count, -1)
      self.second_mod.update_counter(:load_order_notes_count, -1)
      self.submitter.update_counter(:load_order_notes_count, -1)
      self.first_plugin.update_counter(:load_order_notes_count, -1)
      self.second_plugin.update_counter(:load_order_notes_count, -1)
    end
end
