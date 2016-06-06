class CompatibilityNote < ActiveRecord::Base
  include Filterable, RecordEnhancements

  scope :by, -> (id) { where(submitted_by: id) }
  scope :mod, -> (id) { joins(:mod_versions).where(:mod_versions => {mod_id: id}) }
  scope :mv, -> (id) { joins(:mod_versions).where(:mod_versions => {id: id}) }
  scope :type, -> (array) { where(compatibility_type: array) }

  enum status: [ :incompatible, :"partially incompatible", :"compatibility mod", :"compatibility option", :"make custom patch" ]

  belongs_to :game, :inverse_of => 'compatibility_notes'
  belongs_to :user, :foreign_key => 'submitted_by', :inverse_of => 'compatibility_notes'

  # associated mods
  belongs_to :first_mod, :class_name => 'Mod', :foreign_key => 'first_mod_id'
  belongs_to :second_mod, :class_name => 'Mod', :foreign_key => 'second_mod_id'

  # associated compatibility plugin/compatibilty mod for automatic resolution purposes
  belongs_to :compatibility_plugin, :class_name => 'Plugin', :foreign_key => 'compatibility_plugin_id', :inverse_of => 'compatibility_note_plugins'
  belongs_to :compatibility_mod, :class_name => 'Mod', :foreign_key => 'compatibility_mod_id', :inverse_of => 'compatibility_note_mods'

  # mod lists this compatibility note appears on
  has_many :mod_list_compatibility_notes, :inverse_of => 'compatibility_note'
  has_many :mod_lists, :through => 'mod_list_compatibility_notes', :inverse_of => 'compatibility_notes'

  # community feedback on this compatibility note
  has_many :helpful_marks, :as => 'helpfulable'
  has_many :corrections, :as => 'correctable'
  has_one :base_report, :as => 'reportable'

  # old versions of this compatibility note
  has_many :compatibility_note_history_entries, :inverse_of => 'compatibility_note'

  self.per_page = 25

  # Validations
  validates :submitted_by, :status, :text_body, :first_mod_id, :second_mod_id, :game_id, presence: true
  validates :text_body, length: { in: 256..16384 }

  # Callbacks
  after_create :increment_counters
  before_save :set_dates
  before_destroy :decrement_counters

  def mods
    [first_mod, second_mod]
  end

  def recompute_helpful_counts
    self.helpful_count = HelpfulMark.where(helpfulable_id: self.id, helpfulable_type: "CompatibilityNote", helpful: true).count
    self.not_helpful_count = HelpfulMark.where(helpfulable_id: self.id, helpfulable_type: "CompatibilityNote", helpful: false).count
  end

  def as_json(options={})
    if JsonHelpers.json_options_empty(options)
      default_options = {
          :except => [:submitted_by],
          :include => {
              :user => {
                  :only => [:id, :username, :role, :title],
                  :include => {
                      :reputation => {:only => [:overall]}
                  },
                  :methods => :avatar
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
      self.first_mod.update_counter(:compatibility_notes_count, 1)
      self.second_mod.update_counter(:compatibility_notes_count, 1)
      self.user.update_counter(:compatibility_notes_count, 1)
    end

    def decrement_counters
      self.first_mod.update_counter(:compatibility_notes_count, -1)
      self.second_mod.update_counter(:compatibility_notes_count, -1)
      self.user.update_counter(:compatibility_notes_count, -1)
    end
end
