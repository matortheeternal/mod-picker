class LoadOrderNote < ActiveRecord::Base
  include Filterable, Sortable, RecordEnhancements, CounterCache, Correctable, Helpfulable, Reportable, Approveable, ScopeHelpers, Trackable, BetterJson, Dateable

  # ATTRIBUTES
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

  # COUNTER CACHE
  counter_cache_on :first_plugin, :second_plugin, :first_mod, :second_mod, :submitter, conditional: { hidden: false, approved: true }

  # VALIDATIONS
  validates :game_id, :submitted_by, :first_plugin_id, :second_plugin_id, :text_body, presence: true

  validates :text_body, length: {in: 256..16384}
  validate :validate_unique_plugins

  # CALLBACKS
  before_save :set_adult

  def get_existing_note(plugin_ids)
    table = LoadOrderNote.arel_table
    LoadOrderNote.plugins(plugin_ids).where(table[:hidden].eq(0).and(table[:id].not_eq(id))).first
  end

  def note_exists_error(existing_note)
    if existing_note.approved
      errors.add(:plugins, "A Load Order Note for these plugins already exists.")
      errors.add(:link_id, existing_note.id)
    else
      errors.add(:plugins, "An unapproved Load Order Note for these plugins already exists.")
    end
  end

  def duplicate_plugins_error
    errors.add(:plugins, "You cannot create a Load Order Note between a plugin and itself.") if first_plugin_id == second_plugin_id
  end

  def validate_unique_plugins
    return if duplicate_plugins_error
    existing_note = get_existing_note([first_plugin_id, second_plugin_id])
    note_exists_error(existing_note) if existing_note.present?
  end

  def mod_author_users
    User.includes(:mod_authors).where(:mod_authors => {mod_id: [first_mod.id, second_mod.id]})
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
    LoadOrderNote.where(id: ids).joins(:first_mod, :second_mod).update_all("load_order_notes.has_adult_content = mods.has_adult_content OR second_mods_load_order_notes.has_adult_content")
  end

  def self.join_to_mod_options(query, source_column, plugins, options)
    query.join(plugins).on(arel_table[source_column].eq(plugins[:id])).
        join(options).on(plugins[:mod_option_id].eq(options[:id]))
  end

  def self.mod_count_subquery
    mod_options = ModOption.arel_table
    mod_options_alias = ModOption.arel_table.alias
    [
        [:first_plugin_id, Plugin.arel_table, mod_options],
        [:second_plugin_id, Plugin.arel_table.alias, mod_options_alias]
    ].inject(arel_table) { |query, args|
      query = join_to_mod_options(query, *args)
    }.where(Mod.arel_table[:id].eq(mod_options[:mod_id]).
        or(Mod.arel_table[:id].eq(mod_options_alias[:mod_id]))).
        project(Arel.sql('*').count)
  end

  private
    def set_adult
      self.has_adult_content = first_mod.has_adult_content || second_mod.has_adult_content
      true
    end
end
