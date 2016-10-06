class CompatibilityNote < ActiveRecord::Base
  include Filterable, Sortable, RecordEnhancements, Correctable, Helpfulable, Reportable, ScopeHelpers, Trackable, BetterJson

  # ATTRIBUTES
  enum status: [ :incompatible, :partially_incompatible, :compatibility_mod, :compatibility_option, :make_custom_patch ]
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
  belongs_to :compatibility_mod, :class_name => 'Mod', :foreign_key => 'compatibility_mod_id', :inverse_of => 'compatibility_note_mods'

  # mod lists this compatibility note is ignored on
  has_many :mod_list_ignored_notes, :as => 'note'

  # old versions of this compatibility note
  has_many :history_entries, :class_name => 'CompatibilityNoteHistoryEntry', :inverse_of => 'compatibility_note', :foreign_key => 'compatibility_note_id'
  has_many :editors, -> { uniq }, :class_name => 'User', :through => 'history_entries'

  # VALIDATIONS
  validates :game_id, :submitted_by, :status, :first_mod_id, :second_mod_id, :text_body, presence: true
  validates :text_body, length: { in: 256..16384 }
  validate :unique_mods

  # CALLBACKS
  after_create :increment_counters
  before_save :set_adult, :set_dates
  before_destroy :decrement_counters

  def unique_mods
    if first_mod_id == second_mod_id
      errors.add(:mods, "You cannot create a Compatibility Note between a mod and itself.")
      return
    end

    mod_ids = [first_mod_id, second_mod_id]
    note = CompatibilityNote.mods(mod_ids).where("hidden = 0 and id != ?", self.id).first
    if note.present?
      if note.approved
        errors.add(:mods, "A Compatibility Note for these mods already exists.")
        errors.add(:link_id, note.id)
      else
        errors.add(:mods, "An unapproved Compatibility Note for these mods already exists.")
      end
    end
  end

  def mods
    [first_mod, second_mod]
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
  end

  def self.sortable_columns
    {
        :except => [:game_id, :submitted_by, :edited_by, :corrector_id, :first_mod_id, :second_mod_id, :compatibility_mod_id, :compatibility_plugin_id, :text_body, :edit_summary, :moderator_message],
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
      if submitted.nil?
        self.submitted = DateTime.now
      else
        self.edited = DateTime.now
      end
    end

    def set_adult
      self.has_adult_content = first_mod.has_adult_content || second_mod.has_adult_content
      true
    end

    def increment_counters
      first_mod.update_counter(:compatibility_notes_count, 1)
      second_mod.update_counter(:compatibility_notes_count, 1)
      submitter.update_counter(:compatibility_notes_count, 1)
    end

    def decrement_counters
      first_mod.update_counter(:compatibility_notes_count, -1)
      second_mod.update_counter(:compatibility_notes_count, -1)
      submitter.update_counter(:compatibility_notes_count, -1)
    end
end
