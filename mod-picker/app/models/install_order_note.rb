class InstallOrderNote < ActiveRecord::Base
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
  ids_scope :mod_id, :columns => [:first_mod_id, :second_mod_id]
  date_scope :submitted, :edited

  # ASSOCIATIONS
  belongs_to :game, :inverse_of => 'install_order_notes'
  belongs_to :submitter, :class_name => 'User', :foreign_key => 'submitted_by', :inverse_of => 'install_order_notes'
  belongs_to :editor, :class_name => 'User', :foreign_key => 'edited_by'

  has_one :submitter_reputation, :class_name => 'UserReputation', :through => 'submitter', :source => 'reputation'

  # mods associatied with this install order note
  belongs_to :first_mod, :foreign_key => 'first_mod_id', :class_name => 'Mod'
  belongs_to :second_mod, :foreign_key => 'second_mod_id', :class_name => 'Mod'

  # mod lists this install order note appears on
  has_many :mod_list_ignored_notes, :as => 'note'

  # old versions of this install order note
  has_many :history_entries, :class_name => 'InstallOrderNoteHistoryEntry', :inverse_of => 'install_order_note', :foreign_key => 'install_order_note_id'
  has_many :editors, -> { uniq }, :class_name => 'User', :through => 'history_entries'

  # COUNTER CACHE
  counter_cache_on :first_mod, :second_mod, :submitter, conditional: { hidden: false, approved: true }

  # VALIDATIONS
  validates :game_id, :submitted_by, :first_mod_id, :second_mod_id, :text_body, presence: true

  validates :text_body, length: { in: 256..16384 }
  validate :validate_unique_mods

  # CALLBACKS
  before_save :set_adult

  def get_existing_note(mod_ids)
    table = InstallOrderNote.arel_table
    InstallOrderNote.mods(mod_ids).where(table[:hidden].eq(0).and(table[:id].not_eq(id))).first
  end

  def note_exists_error(existing_note)
    if existing_note.approved
      errors.add(:mods, "An Install Order Note for these mods already exists.")
      errors.add(:link_id, existing_note.id)
    else
      errors.add(:mods, "An unapproved Install Order Note for these mods already exists.")
    end
  end

  def duplicate_mods_error
    errors.add(:mods, "You cannot create a Install Order Note between a mod and itself.") if first_mod_id == second_mod_id
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
    history_summary = edited_by.nil? ? "Install Order Note Created" : edit_summary
    history_entries.create(
        edited_by: edited_by || submitted_by,
        text_body: text_body,
        edit_summary: history_summary || "",
        edited: edited || submitted
    )
  end

  def self.update_adult(ids)
    InstallOrderNote.where(id: ids).joins(:first_mod, :second_mod).update_all("install_order_notes.has_adult_content = mods.has_adult_content OR second_mods_install_order_notes.has_adult_content")
  end

  def self.count_subquery
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
