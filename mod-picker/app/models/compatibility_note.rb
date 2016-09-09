class CompatibilityNote < ActiveRecord::Base
  include Filterable, Sortable, RecordEnhancements, Correctable, Helpfulable, Reportable, ScopeHelpers

  enum status: [ :incompatible, :"partially incompatible", :"compatibility mod", :"compatibility option", :"make custom patch" ]

  # SCOPES
  include_scope :hidden
  include_scope :has_adult_content, :alias => 'include_adult'
  visible_scope :approvable => true
  game_scope
  search_scope :text_body, :alias => 'search'
  user_scope :submitter
  enum_scope :status
  ids_scope :mod_id, :columns => [:first_mod_id, :second_mod_id]
  date_scope :submitted, :edited

  # ASSOCIATIONS
  belongs_to :game, :inverse_of => 'compatibility_notes'
  belongs_to :submitter, :class_name => 'User', :foreign_key => 'submitted_by', :inverse_of => 'compatibility_notes'
  belongs_to :editor, :class_name => 'User', :foreign_key => 'edited_by'

  # associated mods
  belongs_to :first_mod, :class_name => 'Mod', :foreign_key => 'first_mod_id'
  belongs_to :second_mod, :class_name => 'Mod', :foreign_key => 'second_mod_id'

  # associated compatibility plugin/compatibilty mod for automatic resolution purposes
  belongs_to :compatibility_plugin, :class_name => 'Plugin', :foreign_key => 'compatibility_plugin_id', :inverse_of => 'compatibility_notes'
  belongs_to :compatibility_mod, :class_name => 'Mod', :foreign_key => 'compatibility_mod_id', :inverse_of => 'compatibility_note_mods'

  # mod lists this compatibility note appears on
  has_many :mod_list_compatibility_notes, :inverse_of => 'compatibility_note'
  has_many :mod_lists, :through => 'mod_list_compatibility_notes', :inverse_of => 'compatibility_notes'
  has_many :mod_list_ignored_notes, :as => 'note'

  # old versions of this compatibility note
  has_many :history_entries, :class_name => 'CompatibilityNoteHistoryEntry', :inverse_of => 'compatibility_note', :foreign_key => 'compatibility_note_id'
  has_many :editors, -> { uniq }, :class_name => 'User', :through => 'history_entries'

  self.per_page = 25

  # VALIDATIONS
  validates :game_id, :submitted_by, :status, :first_mod_id, :second_mod_id, :text_body, presence: true
  validates :text_body, length: { in: 256..16384 }
  validate :unique_mods

  # CALLBACKS
  after_create :increment_counters
  before_save :set_dates
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

  def create_history_entry
    edit_summary = self.edited_by.nil? ? "Compatibility Note Created" : self.edit_summary
    self.history_entries.create(
      edited_by: self.edited_by || self.submitted_by,
      status: self.status,
      compatibility_mod_id: self.compatibility_mod_id,
      compatibility_plugin_id: self.compatibility_plugin_id,
      text_body: self.text_body,
      edit_summary: edit_summary || "",
      edited: self.edited || self.submitted
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
          :methods => :mods
      }
      super(options.merge(default_options))
    else
      super(options)
    end
  end

  def notification_json_options(event_type)
    {
        :only => [(:moderator_message if event_type == :message)].compact,
        :methods => :mods
    }
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
      if self.submitted.nil?
        self.submitted = DateTime.now
      else
        self.edited = DateTime.now
      end
    end

    def increment_counters
      self.first_mod.update_counter(:compatibility_notes_count, 1)
      self.second_mod.update_counter(:compatibility_notes_count, 1)
      self.submitter.update_counter(:compatibility_notes_count, 1)
    end

    def decrement_counters
      self.first_mod.update_counter(:compatibility_notes_count, -1)
      self.second_mod.update_counter(:compatibility_notes_count, -1)
      self.submitter.update_counter(:compatibility_notes_count, -1)
    end
end
