class CompatibilityNote < ActiveRecord::Base
  include Filterable, Sortable, RecordEnhancements, CounterCache, Correctable, Helpfulable, Reportable, Approveable, ScopeHelpers, Searchable, Trackable, BetterJson, Dateable

  # ATTRIBUTES
  enum status: [ :incompatible, :partially_incompatible, :compatibility_mod, :compatibility_option, :make_custom_patch ]
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
  enum_scope :status
  range_scope :overall, :association => 'submitter_reputation', :table => 'user_reputations', :alias => 'reputation'
  ids_scope :mod_id, :columns => [:first_mod_id, :second_mod_id]
  date_scope :submitted, :edited

  # ASSOCIATIONS
  belongs_to :game, :inverse_of => 'compatibility_notes'
  belongs_to :submitter, :class_name => 'User', :foreign_key => 'submitted_by', :inverse_of => 'compatibility_notes'
  belongs_to :editor, :class_name => 'User', :foreign_key => 'edited_by'

  has_one :submitter_reputation, :class_name => 'UserReputation', :through => 'submitter', :source => 'reputation'

  # associated mods
  belongs_to :first_mod, :class_name => 'Mod', :foreign_key => 'first_mod_id'
  belongs_to :second_mod, :class_name => 'Mod', :foreign_key => 'second_mod_id'

  # associated compatibility plugin/compatibilty mod for automatic resolution purposes
  belongs_to :compatibility_plugin, :class_name => 'Plugin', :foreign_key => 'compatibility_plugin_id', :inverse_of => 'compatibility_notes'
  belongs_to :compatibility_mod, :class_name => 'Mod', :foreign_key => 'compatibility_mod_id'
  belongs_to :compatibility_mod_option, :class_name => 'ModOption', :foreign_key => 'compatibility_mod_option_id'

  # mod lists this compatibility note is ignored on
  has_many :mod_list_ignored_notes, :as => 'note'

  # old versions of this compatibility note
  has_many :history_entries, :class_name => 'CompatibilityNoteHistoryEntry', :inverse_of => 'compatibility_note', :foreign_key => 'compatibility_note_id', :dependent => :destroy
  has_many :editors, -> { uniq }, :class_name => 'User', :through => 'history_entries'

  # COUNTER CACHE
  counter_cache_on :first_mod, :second_mod, :submitter, conditional: { hidden: false, approved: true }

  # VALIDATIONS
  validates :game_id, :submitted_by, :status, :first_mod_id, :second_mod_id, :text_body, presence: true
  validates :text_body, length: { in: 128..16384 }
  validate :validate_unique_mods

  # CALLBACKS
  before_save :set_adult

  def get_existing_note(mod_ids)
    table = CompatibilityNote.arel_table
    CompatibilityNote.mods(mod_ids).where(table[:hidden].eq(0).and(table[:id].not_eq(id))).first
  end

  def note_exists_error(existing_note)
    if existing_note.approved
      errors.add(:mods, "A Compatibility Note for these mods already exists.")
      errors.add(:link_id, existing_note.id)
    else
      errors.add(:mods, "An unapproved Compatibility Note for these mods already exists.")
    end
  end

  def duplicate_mods_error
    errors.add(:mods, "You cannot create a Compatibility Note between a mod and itself.") if first_mod_id == second_mod_id
  end

  def validate_unique_mods
    return if duplicate_mods_error
    existing_note = get_existing_note([first_mod_id, second_mod_id])
    note_exists_error(existing_note) if existing_note.present?
  end

  def mod_author_users
    User.includes(:mod_authors).where(:mod_authors => {mod_id: [first_mod_id, second_mod_id]})
  end

  def create_history_entry
    history_summary = edited_by.nil? ? "Compatibility Note Created" : edit_summary
    history_entries.create(
      edited_by: edited_by || submitted_by,
      status: status,
      compatibility_mod_id: compatibility_mod_id,
      compatibility_plugin_id: compatibility_plugin_id,
      text_body: text_body,
      edit_summary: history_summary || "",
      edited: edited || submitted
    )
  end

  def self.update_adult(ids)
    CompatibilityNote.where(id: ids).joins(:first_mod, :second_mod).update_all("compatibility_notes.has_adult_content = mods.has_adult_content OR second_mods_compatibility_notes.has_adult_content")
    Correction.update_adult(CompatibilityNote, ids)
  end

  def self.mod_count_subquery
    arel_table.where(Mod.arel_table[:id].eq(arel_table[:first_mod_id]).
        or(Mod.arel_table[:id].eq(arel_table[:second_mod_id]))).
        project(Arel.sql('*').count)
  end

  private
    def set_adult
      self.has_adult_content = first_mod.has_adult_content || second_mod.has_adult_content
      true
    end
end
