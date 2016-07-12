class InstallOrderNote < ActiveRecord::Base
  include Filterable, Sortable, RecordEnhancements, Correctable, Helpfulable, Reportable

  # BOOLEAN SCOPES (excludes content when false)
  scope :hidden, -> (bool) { where(hidden: false) if !bool  }
  scope :adult, -> (bool) { where(has_adult_content: false) if !bool }
  # GENERAL SCOPES
  scope :visible, -> { where(hidden: false, approved: true) }
  scope :game, -> (game_id) { where(game_id: game_id) }
  scope :search, -> (text) { where("install_order_notes.text_body like ?", "%#{text}%") }
  scope :submitter, -> (username) { joins(:submitter).where(:users => {:username => username}) }
  # RANGE SCOPES
  scope :submitted, -> (range) { where(submitted: parseDate(range[:min])..parseDate(range[:max])) }
  scope :edited, -> (range) { where(edited: parseDate(range[:min])..parseDate(range[:max])) }

  belongs_to :game, :inverse_of => 'install_order_notes'
  belongs_to :submitter, :class_name => 'User', :foreign_key => 'submitted_by', :inverse_of => 'install_order_notes'
  belongs_to :editor, :class_name => 'User', :foreign_key => 'edited_by'

  # mods associatied with this install order note
  belongs_to :first_mod, :foreign_key => 'first_mod_id', :class_name => 'Mod', :inverse_of => 'first_install_order_notes'
  belongs_to :second_mod, :foreign_key => 'second_mod_id', :class_name => 'Mod', :inverse_of => 'second_install_order_notes'

  # mod lists this install order note appears on
  has_many :mod_list_install_order_notes, :inverse_of => 'install_order_note'
  has_many :mod_lists, :through => 'mod_list_install_order_notes', :inverse_of => 'install_order_notes'

  # old versions of this install order note
  has_many :history_entries, :class_name => 'InstallOrderNoteHistoryEntry', :inverse_of => 'install_order_note', :foreign_key => 'install_order_note_id'
  has_many :editors, -> { uniq }, :class_name => 'User', :through => 'history_entries'

  self.per_page = 25

  # Validations
  validates :game_id, :submitted_by, :first_mod_id, :second_mod_id, :text_body, presence: true

  validates :text_body, length: { in: 256..16384 }
  validate :unique_mods

  # Callbacks
  after_create :increment_counters
  before_save :set_dates
  before_destroy :decrement_counters

  def unique_mods
    mod_ids = [first_mod_id, second_mod_id]
    note = InstallOrderNote.where(first_mod_id: mod_ids, second_mod_id: mod_ids, hidden: false).where.not(id: self.id).first
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
