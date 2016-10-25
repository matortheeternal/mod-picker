class LoadOrderNote < ActiveRecord::Base
  include Filterable, Sortable, RecordEnhancements, Correctable, Helpfulable, Reportable, Approveable, ScopeHelpers, Trackable, BetterJson, Dateable

  # ATTRIBUTES
  # this is a hack so the migration will run
  attr_accessor(:first_plugin_id, :second_plugin_id) unless respond_to?(:first_plugin_id)
  self.per_page = 25

  # DATE COLUMNS
  date_column :submitted, :edited

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
  range_scope :overall, :association => 'submitter_reputation', :table => 'user_reputations', :alias => 'reputation'
  ids_scope :plugin_id, :columns => [:first_plugin_id, :second_plugin_id]
  date_scope :submitted, :edited

  # UNIQUE SCOPES
  scope :plugin_filename, -> (filename) { joins(:first_plugin, :second_plugin).where("plugins.filename like ?", "%#{filename}%") }

  # ASSOCIATIONS
  belongs_to :game, :inverse_of => 'load_order_notes'
  belongs_to :submitter, :class_name => 'User', :foreign_key => 'submitted_by', :inverse_of => 'load_order_notes'
  belongs_to :editor, :class_name => 'User', :foreign_key => 'edited_by'

  has_one :submitter_reputation, :class_name => 'UserReputation', :through => 'submitter', :source => 'reputation'

  # plugins associatied with this load order note
  has_many :plugin_load_order_notes, -> { order(:index) }
  has_many :plugins, :through => :plugin_load_order_notes
  has_many :mods, :through => :plugin_load_order_notes

  # mod lists this load order note is ignored on
  has_many :mod_list_ignored_notes, :as => 'note'

  # old versions of this load order note
  has_many :history_entries, :class_name => 'LoadOrderNoteHistoryEntry', :inverse_of => 'load_order_note', :foreign_key => 'load_order_note_id'
  has_many :editors, -> { uniq }, :class_name => 'User', :through => 'history_entries'

  # VALIDATIONS
  validates :game_id, :submitted_by, :text_body, presence: true
  validates :text_body, length: {in: 256..16384}

  # CALLBACKS
  after_create :increment_counters
  before_save :set_adult
  before_destroy :decrement_counters

  # TODO: Make some kind of shortcut method macro for these
  def first_plugin
    plugins.first
  end

  def second_plugin
    plugins.second
  end

  def first_mod
    first_plugin.mod
  end

  def second_mod
    second_plugin.mod
  end

  def mod_author_users
    User.includes(:mod_authors).where(:mod_authors => {mod_id: mods.ids})
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

  def self.update_adult(ids)
    find(ids).joins(:mods).update_all("load_order_notes.has_adult_content = mods.has_adult_content")
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
    def set_adult
      self.has_adult_content = first_mod.has_adult_content || second_mod.has_adult_content
      true
    end

    def increment_counters
      first_mod.update_counter(:load_order_notes_count, 1)
      second_mod.update_counter(:load_order_notes_count, 1)
      submitter.update_counter(:load_order_notes_count, 1)
      first_plugin.update_counter(:load_order_notes_count, 1)
      second_plugin.update_counter(:load_order_notes_count, 1)
    end

    def decrement_counters
      first_mod.update_counter(:load_order_notes_count, -1)
      second_mod.update_counter(:load_order_notes_count, -1)
      submitter.update_counter(:load_order_notes_count, -1)
      first_plugin.update_counter(:load_order_notes_count, -1)
      second_plugin.update_counter(:load_order_notes_count, -1)
    end
end
