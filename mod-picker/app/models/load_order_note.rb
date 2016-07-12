class LoadOrderNote < ActiveRecord::Base
  include Filterable, Sortable, RecordEnhancements, Correctable, Helpfulable, Reportable

  # BOOLEAN SCOPES (excludes content when false)
  scope :hidden, -> (bool) { where(hidden: false) if !bool  }
  scope :adult, -> (bool) { where(has_adult_content: false) if !bool }
  # GENERAL SCOPES
  scope :visible, -> { where(hidden: false, approved: true) }
  scope :game, -> (game_id) { where(game_id: game_id) }
  scope :search, -> (text) { where("load_order_notes.text_body like ?", "%#{text}%") }
  scope :plugin_filename, -> (filename) { joins(:first_plugin, :second_plugin).where("plugins.filename like ?", "%#{filename}%") }
  scope :submitter, -> (username) { joins(:submitter).where(:users => {:username => username}) }
  # RANGE SCOPES
  scope :submitted, -> (range) { where(submitted: parseDate(range[:min])..parseDate(range[:max])) }
  scope :edited, -> (range) { where(edited: parseDate(range[:min])..parseDate(range[:max])) }

  belongs_to :game, :inverse_of => 'load_order_notes'
  belongs_to :submitter, :class_name => 'User', :foreign_key => 'submitted_by', :inverse_of => 'load_order_notes'
  belongs_to :editor, :class_name => 'User', :foreign_key => 'edited_by'

  # plugins associatied with this load order note
  belongs_to :first_plugin, :foreign_key => 'first_plugin_id', :class_name => 'Plugin', :inverse_of => 'first_load_order_notes'
  belongs_to :second_plugin, :foreign_key => 'second_plugin_id', :class_name => 'Plugin', :inverse_of => 'second_load_order_notes'

  # mods associated with this load order note
  has_one :first_mod, :through => :first_plugin, :class_name => 'Mod', :source => 'mod', :foreign_key => 'mod_id'
  has_one :second_mod, :through => :second_plugin, :class_name => 'Mod', :source => 'mod', :foreign_key => 'mod_id'

  # mod lists this load order note appears on
  has_many :mod_list_installation_notes, :inverse_of => 'load_order_note'
  has_many :mod_lists, :through => 'mod_list_load_order_notes', :inverse_of => 'load_order_notes'

  # old versions of this load order note
  has_many :history_entries, :class_name => 'LoadOrderNoteHistoryEntry', :inverse_of => 'load_order_note', :foreign_key => 'load_order_note_id'
  has_many :editors, -> { uniq }, :class_name => 'User', :through => 'history_entries'

  self.per_page = 25

  # Validations
  validates :game_id, :submitted_by, :first_plugin_id, :second_plugin_id, :text_body, presence: true

  validates :text_body, length: {in: 256..16384}
  validate :unique_plugins

  # Callbacks
  after_create :increment_counters
  before_save :set_dates
  before_destroy :decrement_counters

  def unique_plugins
    if first_plugin_id == second_plugin_id
      errors.add(:plugins, "You cannot create a Load Order Note between a plugin and itself.")
      return
    end

    plugin_ids = [first_plugin_id, second_plugin_id]
    note = LoadOrderNote.where(first_plugin_id: plugin_ids, second_plugin_id: plugin_ids, hidden: false).where.not(id: self.id).first
    if note.present?
      if note.approved
        errors.add(:plugins, "A Load Order Note for these plugins already exists.")
        errors.add(:link_id, note.id)
      else
        errors.add(:plugins, "An unapproved Load Order Note for these plugins already exists.")
      end
    end
  end

  def mods
    [first_mod, second_mod]
  end

  def plugins
    [first_plugin, second_plugin]
  end

  def create_history_entry
    edit_summary = self.edited_by.nil? ? "Load Order Note Created" : self.edit_summary
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
      byebug
      self.first_mod.update_counter(:load_order_notes_count, 1)
      self.second_mod.update_counter(:load_order_notes_count, 1)
      self.submitter.update_counter(:load_order_notes_count, 1)
      self.first_plugin.update_counter(:load_order_notes_count, 1)
      self.second_plugin.update_counter(:load_order_notes_count, 1)
    end

    def decrement_counters
      self.first_mod.update_counter(:load_order_notes_count, -1)
      self.second_mod.update_counter(:load_order_notes_count, -1)
      self.submitter.update_counter(:load_order_notes_count, -1)
      self.first_plugin.update_counter(:load_order_notes_count, -1)
      self.second_plugin.update_counter(:load_order_notes_count, -1)
    end
end
