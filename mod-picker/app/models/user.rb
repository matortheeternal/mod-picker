class User < ActiveRecord::Base
  include Filterable, Sortable, RecordEnhancements, CounterCache, Imageable, Reportable, ScopeHelpers, Trackable, BetterJson

  # Include devise modules
  devise :invitable, :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  # ATTRIBUTES
  attr_accessor :login
  self.per_page = 50

  # EVENT TRACKING
  track :status, :column => 'role'

  # NOTIFICATION SUBSCRIPTIONS
  subscribe :user, to: [:message, :status]

  # SCOPES
  search_scope :username, :alias => 'search'
  hash_scope :role
  counter_scope :authored_mods_count, :mod_lists_count, :submitted_comments_count, :comments_count, :reviews_count, :compatibility_notes_count, :install_order_notes_count, :load_order_notes_count, :corrections_count
  range_scope :overall, :association => 'reputation', :table => 'user_reputations', :alias => 'reputation'
  date_scope :joined
  date_scope :last_sign_in_at, :alias => 'last_seen'

  # UNIQUE SCOPES
  scope :include_blank, -> (bool) { where.not(username: nil) if !bool }
  scope :contributors, -> (mod) {
    # TODO: Handle appeals too
    includes(:reviews => :mod, :compatibility_notes => [:first_mod, :second_mod], :install_order_notes => [:first_mod, :second_mod], :load_order_notes => [:first_mod, :second_mod]).where(:mods => {id: mod.id})
  }
  scope :linked, -> (search) { joins(:bio).where("nexus_username like :search OR lover_username like :search OR workshop_username like :search", search: "#{search}%") }

  # ASSOCIATIONS
  has_one :settings, :class_name => 'UserSetting', :dependent => :destroy
  has_one :bio, :class_name => 'UserBio', :dependent => :destroy
  has_one :reputation, :class_name => 'UserReputation', :dependent => :destroy

  has_many :articles, :foreign_key => 'submitted_by', :inverse_of => 'submitter'
  has_many :help_pages, :foreign_key => 'submitted_by', :inverse_of => 'submitter'
  has_many :comments, :foreign_key => 'submitted_by', :inverse_of => 'submitter'
  has_many :install_order_notes, :foreign_key => 'submitted_by', :inverse_of => 'submitter'
  has_many :load_order_notes, :foreign_key => 'submitted_by', :inverse_of => 'submitter'
  has_many :compatibility_notes, :foreign_key => 'submitted_by', :inverse_of => 'submitter'
  has_many :reviews, :foreign_key => 'submitted_by', :inverse_of => 'submitter'
  has_many :corrections, :foreign_key => 'submitted_by', :inverse_of => 'submitter'
  has_many :agreement_marks, :foreign_key => 'submitted_by', :inverse_of => 'submitter'
  has_many :helpful_marks, :foreign_key => 'submitted_by', :inverse_of => 'submitter'

  has_many :compatibility_note_history_entries, :foreign_key => 'submitted_by', :inverse_of => 'submitter'
  has_many :install_order_note_history_entries, :foreign_key => 'submitted_by', :inverse_of => 'submitter'
  has_many :load_order_note_history_entries, :foreign_key => 'submitted_by', :inverse_of => 'submitter'

  has_many :tags, :foreign_key => 'submitted_by', :inverse_of => 'submitter'
  has_many :mod_tags, :foreign_key => 'submitted_by', :inverse_of => 'submitter'
  has_many :mod_list_tags, :foreign_key => 'submitted_by', :inverse_of => 'submitter'

  has_many :submitted_mods, :class_name => 'Mod', :foreign_key => 'submitted_by', :inverse_of => 'submitter'

  has_many :curator_requests, :inverse_of => 'submitter'

  has_many :mod_authors, :inverse_of => 'user'
  has_many :mods, :through => 'mod_authors', :inverse_of => 'author_users'
  has_many :mod_lists, :foreign_key => 'submitted_by', :inverse_of => 'submitter'

  belongs_to :active_mod_list, :class_name => 'ModList', :foreign_key => 'active_mod_list_id'

  has_many :mod_stars, :inverse_of => 'user'
  has_many :starred_mods, :class_name => 'Mod', :through => 'mod_stars', :source => 'mod', :inverse_of => 'user_stars'

  has_many :mod_list_stars, :inverse_of => 'user'
  has_many :starred_mod_lists, :class_name => 'ModList', :through => 'mod_list_stars', :source => 'mod_list', :inverse_of => 'user_stars'

  has_many :profile_comments, -> { where(parent_id: nil) }, :class_name => 'Comment', :as => 'commentable'
  has_many :reports, :foreign_key => 'submitted_by', :inverse_of => 'submitter'

  has_many :notifications, -> { includes(:event).order("events.created DESC, events.id DESC") }, :inverse_of => 'user'
  has_many :messages, :inverse_of => 'recipient', :foreign_key => 'sent_to'
  has_many :sent_messages, :class_name => 'Message', :inverse_of => 'submitter', :foreign_key => 'submitter_by'

  has_many :api_tokens, inverse_of: 'user'

  accepts_nested_attributes_for :settings, reject_if: :new_record?

  # COUNTER CACHE
  counter_cache :profile_comments, column: 'comments_count', conditional: { hidden: false }
  counter_cache :comments, column: 'submitted_comments_count', conditional: { hidden: false }
  counter_cache :starred_mods, :starred_mod_lists, :mod_tags, :mod_list_tags, :helpful_marks, :agreement_marks
  counter_cache :mod_authors, column: 'authored_mods_count'
  counter_cache :submitted_mods, :reviews, :compatibility_notes, :install_order_notes, :load_order_notes, conditional: { hidden: false, approved: true }
  counter_cache  :corrections, :tags, conditional: { hidden: false }
  bool_counter_cache :mod_lists, :is_collection, { true => :mod_collections, false => :mod_lists }

  # VALIDATIONS
  validates :username, :email, :role, presence: true
  validates :username, uniqueness: { case_sensitive: false }, length: {in: 4..32 }
  validates :email, uniqueness: { case_sensitive: false }, length: {in: 7..255}
  validates_format_of :email, :with => /\A\S+@.+\.\S+\z/
  validates :about_me, length: {maximum: 16384}

  # CALLBACKS
  after_create :create_associations
  after_initialize :init

  def user
    User.find(id)
  end

  def recent_notifications
    notifications.unread.limit(10)
  end

  def admin?
    role.to_sym == :admin
  end

  def moderator?
    role.to_sym == :moderator
  end

  def can_moderate?
    admin? || moderator?
  end

  def news_writer?
    role.to_sym == :writer
  end

  def helper?
    role.to_sym == :helper
  end

  def restricted?
    role.to_sym == :restricted
  end

  def banned?
    role.to_sym == :banned
  end

  def inactive?
    last_sign_in_at.nil? || last_sign_in_at < 28.days.ago
  end

  def email_public?
    settings.email_public
  end

  def comments_disabled?
    !settings.allow_comments
  end

  def has_auto_approval?
    reputation.overall > 40
  end

  def has_mod_auto_approval?
    reputation.overall > 160
  end

  def subscribed_to?(event)
    if respond_to?(:notification_settings)
      key = "#{event.content_type.underscore}_#{event.event_type}"
      notification_settings.public_send(key.to_sym)
    else
      true
    end
  end

  def update_mod_author_role
    if ["user", "mod_author"].include?(role)
      is_author = mod_authors.where("role != 2").exists?
      new_role = is_author ? "author" : "user"
      update_column(:role, new_role) if role != new_role
    end
  end

  def mod_submission_history(time_zone)
    submitted_mods.submission_history(time_zone)
  end

  def init
    self.joined ||= DateTime.current
    self.role   ||= :user
  end

  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if (login = conditions.delete(:login))
      where(conditions).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
    else
      if conditions[:username].nil?
        where(conditions).first
      else
        where(username: conditions[:username]).first
      end
    end
  end

  def self.failed_emails
    @failed_emails ||= []
  end

  def self.batch_invite!(emails, current_inviter)
    emails.each do |email|
      if /\A\S+@.+\.\S+\z/.match(email)
        User.invite!({:email => email}, current_inviter)
      else
        failed_emails.push(email)
      end
    end

    failed_emails.empty?
  end

  def create_associations
    create_reputation(user_id: id)
    create_settings(user_id: id)
    create_bio(user_id: id)
  end
end
