class LoadOrderNote < ActiveRecord::Base
  include Filterable, Sortable, RecordEnhancements, CounterCache, Correctable, Helpfulable, Reportable, Approveable, ScopeHelpers, Searchable, Trackable, BetterJson, Dateable

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
  hash_scope :approved, alias: 'approved'
  hash_scope :hidden, alias: 'hidden'
  hash_scope :adult, alias: 'adult', column: 'has_adult_content'
  include_scope :hidden
  visible_scope :approvable => true
  game_scope
  range_scope :overall, :association => 'submitter_reputation', :table => 'user_reputations', :alias => 'reputation'
  date_scope :submitted, :edited

  # UNIQUE SCOPES
  scope :plugins, -> (filenames) { joins("INNER JOIN plugins first_plugins ON first_plugins.filename = load_order_notes.first_plugin_filename").joins("INNER JOIN plugins second_plugins ON second_plugins.filename = load_order_notes.second_plugin_filename").where("first_plugins.filename in (:filenames) OR second_plugins.filename in (:filenames)", filenames: filenames) }
  scope :plugin, -> (filenames) { joins("INNER JOIN plugins first_plugins ON first_plugins.filename = load_order_notes.first_plugin_filename").joins("INNER JOIN plugins second_plugins ON second_plugins.filename = load_order_notes.second_plugin_filename").where("first_plugins.filename in (:filenames) AND second_plugins.filename in (:filenames)", filenames: filenames)}
  # TODO AREL
  scope :mod_list, -> (mod_list_id) { joins("INNER JOIN mod_list_plugins").joins("INNER JOIN plugins ON mod_list_plugins.plugin_id = plugins.id").where("mod_list_plugins.mod_list_id = ?", mod_list_id).where("load_order_notes.first_plugin_filename = plugins.filename OR load_order_notes.second_plugin_filename = plugins.filename").distinct }

  # ASSOCIATIONS
  belongs_to :game, :inverse_of => 'load_order_notes'
  belongs_to :submitter, :class_name => 'User', :foreign_key => 'submitted_by', :inverse_of => 'load_order_notes'
  belongs_to :editor, :class_name => 'User', :foreign_key => 'edited_by'

  has_one :submitter_reputation, :class_name => 'UserReputation', :through => 'submitter', :source => 'reputation'

  # mod lists this load order note is ignored on
  has_many :mod_list_ignored_notes, :as => 'note'

  # old versions of this load order note
  has_many :history_entries, :class_name => 'LoadOrderNoteHistoryEntry', :inverse_of => 'load_order_note', :foreign_key => 'load_order_note_id', :dependent => :destroy
  has_many :editors, -> { uniq }, :class_name => 'User', :through => 'history_entries'

  # COUNTER CACHE
  counter_cache_on :submitter, conditional: { hidden: false, approved: true }
  # :first_plugin, :second_plugin, :first_mod, :second_mod,

  # VALIDATIONS
  validates :game_id, :submitted_by, :first_plugin_filename, :second_plugin_filename, :text_body, presence: true

  validates :text_body, length: {in: 128..16384}
  validate :validate_unique_plugins
  validate :validate_no_master_dependency

  # CALLBACKS
  before_save :set_adult

  def get_existing_note(plugin_filenames)
    table = LoadOrderNote.arel_table
    LoadOrderNote.plugin(plugin_filenames).where(table[:hidden].eq(0).and(table[:id].not_eq(id))).first
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
    errors.add(:plugins, "You cannot create a Load Order Note between a plugin and itself.") if first_plugin_filename == second_plugin_filename
  end

  def validate_unique_plugins
    return if duplicate_plugins_error
    existing_note = get_existing_note([first_plugin_filename, second_plugin_filename])
    note_exists_error(existing_note) if existing_note.present?
  end

  def plugin_is_master
    false
    #second_plugin.masters.pluck(:master_plugin_id).include?(first_plugin.id) ||
    #   first_plugin.masters.pluck(:master_plugin_id).include?(second_plugin.id)
  end

  def validate_no_master_dependency
    errors.add(:plugins, "Load Order Notes for plugins with master dependencies are redundant.") if plugin_is_master
  end

  def mod_ids
    Mod.joins(:plugins).where("plugins.filename in (?)", [first_plugin_filename, second_plugin_filename]).ids
  end

  def mod_author_users
    User.joins(:mod_authors).where(:mod_authors => {mod_id: [mod_ids]})
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
    # TODO: Restore SQL here
    #LoadOrderNote.where(id: ids).joins("INNER JOIN plugins ON plugins.filename = load_order_note.first_plugin_filename OR plugins.filename = load_order_note.second_plugin_filename").joins("INNER JOIN mod_options ON mod_options.id = plugins.mod_option_id").joins("INNER JOIN mods ON mods.id = mod_options.mod_id").update_all("load_order_notes.has_adult_content = mods.has_adult_content")
    LoadOrderNote.where(id: ids).each{ |note| note.set_adult }
    Correction.update_adult(LoadOrderNote, ids)
  end

  def self.join_to_mod_options(query, source_column, plugins, options)
    query.join(plugins).on(arel_table[source_column].eq(plugins[:filename])).
        join(options).on(plugins[:mod_option_id].eq(options[:id]))
  end

  def self.mod_count_subquery
    mod_options = ModOption.arel_table
    mod_options_alias = ModOption.arel_table.alias
    [
        [:first_plugin_filename, Plugin.arel_table, mod_options],
        [:second_plugin_filename, Plugin.arel_table.alias, mod_options_alias]
    ].inject(arel_table) { |query, args|
      query = join_to_mod_options(query, *args)
    }.where(Mod.arel_table[:id].eq(mod_options[:mod_id]).
        or(Mod.arel_table[:id].eq(mod_options_alias[:mod_id]))).
        project(Arel.sql('*').count)
  end

  def self.plugin_count_subquery
    where(Plugin.arel_table[:filename].eq(arel_table[:first_plugin_filename]).
        or(Plugin.arel_table[:filename].eq(arel_table[:second_plugin_filename]))).
        project(Arel.sql('*').count)
  end

  def set_adult
    self.has_adult_content = Mod.joins(:plugins).where("plugins.filename in (?)", [first_plugin_filename, second_plugin_filename]).pluck(:has_adult_content).reduce(:|)
    true
  end
end
