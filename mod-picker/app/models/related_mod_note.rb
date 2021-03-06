class RelatedModNote < ActiveRecord::Base
  include Filterable, Sortable, RecordEnhancements, CounterCache, Helpfulable, Reportable, Approveable, ScopeHelpers, Searchable, Trackable, BetterJson, Dateable

  # ATTRIBUTES
  enum status: [ :alternative_mod, :recommended_mod ]
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
  belongs_to :game, :inverse_of => 'related_mod_notes'
  belongs_to :submitter, :class_name => 'User', :foreign_key => 'submitted_by', :inverse_of => 'related_mod_notes'
  belongs_to :editor, :class_name => 'User', :foreign_key => 'edited_by'

  has_one :submitter_reputation, :class_name => 'UserReputation', :through => 'submitter', :source => 'reputation'

  # associated mods
  belongs_to :first_mod, :class_name => 'Mod', :foreign_key => 'first_mod_id'
  belongs_to :second_mod, :class_name => 'Mod', :foreign_key => 'second_mod_id'

  # old versions of this related mod note
  # has_many :history_entries, :class_name => 'RelatedModNoteHistoryEntry', :inverse_of => 'related_mod_note', :foreign_key => 'related_mod_note_id', :dependent => :destroy
  # has_many :editors, -> { uniq }, :class_name => 'User', :through => 'history_entries'

  # COUNTER CACHE
  counter_cache_on :first_mod, :second_mod, :submitter, conditional: { hidden: false, approved: true }

  # VALIDATIONS
  validates :game_id, :submitted_by, :status, :first_mod_id, :second_mod_id, :text_body, presence: true
  validates :text_body, length: { in: 128..16384 }
  validate :validate_unique_mods

  # CALLBACKS
  before_save :set_adult

  def get_existing_note(mod_ids)
    table = RelatedModNote.arel_table
    RelatedModNote.mods(mod_ids).where(table[:hidden].eq(0).and(table[:id].not_eq(id))).first
  end

  def note_exists_error(existing_note)
    if existing_note.approved
      errors.add(:mods, "A Related Mod Note for these mods already exists.")
      errors.add(:link_id, existing_note.id)
    else
      errors.add(:mods, "An unapproved Related Mod Note for these mods already exists.")
    end
  end

  def duplicate_mods_error
    errors.add(:mods, "You cannot create a Related Mod Note between a mod and itself.") if first_mod_id == second_mod_id
  end

  def validate_unique_mods
    return if duplicate_mods_error
    existing_note = get_existing_note([first_mod_id, second_mod_id])
    note_exists_error(existing_note) if existing_note.present?
  end

  def mod_author_users
    User.includes(:mod_authors).where(:mod_authors => {mod_id: [first_mod_id, second_mod_id]})
  end

  # def create_history_entry
  #   history_summary = edited_by.nil? ? "Related Mod Note Created" : edit_summary
  #   history_entries.create(
  #     edited_by: edited_by || submitted_by,
  #     status: status,
  #     text_body: text_body,
  #     edit_summary: history_summary || "",
  #     edited: edited || submitted
  #   )
  # end

  def self.update_adult(ids)
    RelatedModNote.where(id: ids).joins(:first_mod, :second_mod).update_all("related_mod_notes.has_adult_content = mods.has_adult_content OR second_mods_related_mod_notes.has_adult_content")
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
