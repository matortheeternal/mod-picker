class InstallOrderNote < ActiveRecord::Base
  include Filterable, Sortable, RecordEnhancements

  scope :by, -> (id) { where(submitted_by: id) }
  scope :mod, -> (id) { joins(:mod_versions).where(:mod_versions => {mod_id: id}) }
  scope :mv, -> (id) { joins(:mod_versions).where(:mod_versions => {id: id}) }

  belongs_to :game, :inverse_of => 'install_order_notes'
  belongs_to :submitter, :class_name => 'User', :foreign_key => 'submitted_by', :inverse_of => 'install_order_notes'

  # mods associatied with this install order note
  belongs_to :first_mod, :foreign_key => 'first_mod_id', :class_name => 'Mod', :inverse_of => 'first_install_order_notes'
  belongs_to :second_mod, :foreign_key => 'second_mod_id', :class_name => 'Mod', :inverse_of => 'second_install_order_notes'

  # mod lists this install order note appears on
  has_many :mod_list_install_order_notes, :inverse_of => 'install_order_note'
  has_many :mod_lists, :through => 'mod_list_install_order_notes', :inverse_of => 'install_order_notes'

  # community feedback on this install order note
  has_many :helpful_marks, :as => 'helpfulable'
  has_many :corrections, :as => 'correctable'

  # old versions of this install order note
  has_many :history_entries, :class_name => 'InstallOrderNoteHistoryEntry', :inverse_of => 'install_order_note', :foreign_key => 'install_order_note_id'

  self.per_page = 25

  # Validations
  validates :first_mod_id, :second_mod_id, presence: true
  validates :text_body, length: { in: 256..16384 }

  # Callbacks
  after_create :increment_counters
  before_save :set_dates
  before_destroy :decrement_counters

  def mods
    [first_mod, second_mod]
  end

  def compute_reputation
    # TODO: We could base this off of the reputation of the people who marked the review helpful/not helpful, but we aren't doing that yet
    user_rep = self.user.reputation.overall
    helpfulness = (self.helpful_count - self.not_helpful_count)
    if user_rep < 0
      self.reputation = user_rep + helpfulness
    else
      user_rep_factor = 2 / (1 + Math::exp(-0.0075 * (user_rep - 640)))
      if self.helpful_count < self.not_helpful_count
        self.reputation = (1 - user_rep_factor / 2) * helpfulness
      else
        self.reputation = (1 + user_rep_factor) * helpfulness
      end
    end
  end

  def recompute_helpful_counts
    self.helpful_count = HelpfulMark.where(helpfulable_id: self.id, helpfulable_type: "InstallOrderNote", helpful: true).count
    self.not_helpful_count = HelpfulMark.where(helpfulable_id: self.id, helpfulable_type: "InstallOrderNote", helpful: false).count
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
      self.user.update_counter(:install_order_notes_count, 1)
    end

    def decrement_counters
      self.first_mod.update_counter(:install_order_notes_count, -1)
      self.second_mod.update_counter(:install_order_notes_count, -1)
      self.user.update_counter(:install_order_notes_count, -1)
    end
end
