class InstallOrderNote < ActiveRecord::Base
  include Filterable, Sortable, RecordEnhancements, Correctable, Helpfulable, Reportable, ScopeHelpers, Trackable

  # ATTRIBUTES
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

  # VALIDATIONS
  validates :game_id, :submitted_by, :first_mod_id, :second_mod_id, :text_body, presence: true

  validates :text_body, length: { in: 256..16384 }
  validate :unique_mods

  # CALLBACKS
  after_create :increment_counters
  before_save :set_adult, :set_dates
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

  def as_json(options={})
    if JsonHelpers.json_options_empty(options)
      default_options = {
          :except => [:submitted_by],
          :include => {
              :submitter => {
                  :only => [:id, :username, :role, :title, :joined, :last_sign_in_at, :reviews_count, :compatibility_notes_count, :install_order_notes_count, :load_order_notes_count, :corrections_count, :comments_count],
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
              },
              :first_mod => {
                  :only => [:id, :name]
              },
              :second_mod => {
                  :only => [:id, :name]
              }
          }
      }
      super(options.merge(default_options))
    else
      super(options)
    end
  end

  def notification_json_options(event_type)
    {
        :only => [:submitted_by, (:moderator_message if event_type == :message)].compact,
        :methods => :mods
    }
  end

  # TODO: trim down reportable json options
  def reportable_json_options
    {
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
  end

  def self.sortable_columns
    {
        :except => [:game_id, :submitted_by, :edited_by, :corrector_id, :first_mod_id, :second_mod_id, :text_body, :edit_summary, :moderator_message],
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

    def set_adult
      self.has_adult_content = first_mod.has_adult_content || second_mod.has_adult_content
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
