class InstallOrderNote < ActiveRecord::Base
  include Filterable, Sortable, RecordEnhancements, Correctable, Helpfulable, Reportable, ScopeHelpers

  # SCOPES
  include_scope :hidden
  include_scope :has_adult_content, :alias => 'include_adult'
  visible_scope :approvable => true
  game_scope
  search_scope :text_body, :alias => 'search'
  user_scope :submitter
  ids_scope :mod_id, :columns => [:first_mod_id, :second_mod_id]
  date_scope :submitted, :edited

  belongs_to :game, :inverse_of => 'install_order_notes'
  belongs_to :submitter, :class_name => 'User', :foreign_key => 'submitted_by', :inverse_of => 'install_order_notes'
  belongs_to :editor, :class_name => 'User', :foreign_key => 'edited_by'

  # mods associatied with this install order note
  belongs_to :first_mod, :foreign_key => 'first_mod_id', :class_name => 'Mod'
  belongs_to :second_mod, :foreign_key => 'second_mod_id', :class_name => 'Mod'

  # mod lists this install order note appears on
  has_many :mod_list_install_order_notes, :inverse_of => 'install_order_note'
  has_many :mod_lists, :through => 'mod_list_install_order_notes', :inverse_of => 'install_order_notes'
  has_many :mod_list_ignored_notes, :as => 'note'

  # old versions of this install order note
  has_many :history_entries, :class_name => 'InstallOrderNoteHistoryEntry', :inverse_of => 'install_order_note', :foreign_key => 'install_order_note_id'
  has_many :editors, -> { uniq }, :class_name => 'User', :through => 'history_entries'

  self.per_page = 25

  # VALIDATIONS
  validates :game_id, :submitted_by, :first_mod_id, :second_mod_id, :text_body, presence: true

  validates :text_body, length: { in: 256..16384 }
  validate :unique_mods

  # CALLBACKS
  after_create :increment_counters
  before_save :set_dates
  before_destroy :decrement_counters

  def unique_mods
    if first_mod_id == second_mod_id
      errors.add(:mods, "You cannot create a Install Order Note between a mod and itself.")
      return
    end

    mod_ids = [first_mod_id, second_mod_id]
    note = InstallOrderNote.mods(mod_ids).where("hidden = 0 and id != ?", self.id).first
    if note.present?
      if note.approved
        errors.add(:mods, "An Install Order Note for these mods already exists.")
        errors.add(:link_id, note.id)
      else
        errors.add(:mods, "An unapproved Install Order Note for these mods already exists.")
      end
    end
  end

  def mods
    [first_mod, second_mod]
  end

  def create_history_entry
    edit_summary = self.edited_by.nil? ? "Install Order Note Created" : self.edit_summary
    self.history_entries.create(
        edited_by: self.edited_by || self.submitted_by,
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

  private
    def set_dates
      if self.submitted.nil?
        self.submitted = DateTime.now
      else
        self.edited = DateTime.now
      end
    end

    def increment_counters
      self.first_mod.update_counter(:install_order_notes_count, 1)
      self.second_mod.update_counter(:install_order_notes_count, 1)
      self.submitter.update_counter(:install_order_notes_count, 1)
    end

    def decrement_counters
      self.first_mod.update_counter(:install_order_notes_count, -1)
      self.second_mod.update_counter(:install_order_notes_count, -1)
      self.submitter.update_counter(:install_order_notes_count, -1)
    end
end
