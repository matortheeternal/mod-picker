class User < ActiveRecord::Base
  include Filterable, Sortable, RecordEnhancements, Imageable, Reportable, ScopeHelpers, Trackable

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  # ATTRIBUTES
  attr_accessor :login
  self.per_page = 50

  # EVENT TRACKING
  track :status, :column => 'role'

  # NOTIFICATION SUBSCRIPTIONS
  subscribe :self, to: [:message, :status, *Event.milestones]

  # SCOPES
  search_scope :username, :alias => 'search'
  hash_scope :role
  counter_scope :authored_mods_count, :mod_lists_count, :comments_count, :reviews_count, :compatibility_notes_count, :install_order_notes_count, :load_order_notes_count, :corrections_count
  range_scope :overall, :association => 'reputation', :table => 'user_reputations'
  date_scope :joined
  date_scope :last_sign_in_at, :alias => 'last_seen'

  # UNIQUE SCOPES
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

  has_many :mod_authors, :inverse_of => 'user'
  has_many :mods, :through => 'mod_authors', :inverse_of => 'author_users'
  has_many :mod_lists, :foreign_key => 'submitted_by', :inverse_of => 'submitter'

  belongs_to :active_mod_list, :class_name => 'ModList', :foreign_key => 'active_mod_list_id'

  has_many :mod_stars, :inverse_of => 'user'
  has_many :starred_mods, :through => 'mod_stars', :source => 'mod'

  has_many :mod_list_stars, :inverse_of => 'user'
  has_many :starred_mod_lists, :through => 'mod_list_stars', :source => 'mod_list'

  has_many :profile_comments, -> { where(parent_id: nil) }, :class_name => 'Comment', :as => 'commentable'
  has_many :reports, :foreign_key => 'submitted_by', :inverse_of => 'submitter'

  has_many :notifications, -> { includes(:event).order("events.created DESC") }, :inverse_of => 'user'
  has_many :messages, :inverse_of => 'recipient', :foreign_key => 'sent_to'
  has_many :sent_messages, :class_name => 'Message', :inverse_of => 'submitter', :foreign_key => 'submitter_by'

  accepts_nested_attributes_for :settings, reject_if: :new_record?

  # VALIDATIONS
  validates :username, :email, :role, presence: true
  validates :username, uniqueness: { case_sensitive: false }, length: {in: 4..32 }

  # email validation
  validates :email, uniqueness: { case_sensitive: false }, length: {in: 7..255}
  validates_format_of :email, :with => /\A\S+@.+\.\S+\z/

  validates :about_me, length: {maximum: 16384}

  # CALLBACKS
  after_create :create_associations
  after_initialize :init

  # alias for image method
  def avatar
    png_path = File.join(Rails.public_path, "users/#{id}.png")
    jpg_path = File.join(Rails.public_path, "users/#{id}.jpg")
    if File.exists?(png_path)
      "/users/#{id}.png"
    elsif File.exists?(jpg_path)
      "/users/#{id}.jpg"
    elsif self.title.nil?
      nil
    else
      "/users/Default.png"
    end
  end

  def recent_notifications
    notifications.unread.limit(10)
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

  def admin?
    role.to_sym == :admin
  end

  def moderator?
    role.to_sym == :moderator
  end

  def can_moderate?
    admin? || moderator?
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

  def subscribed_to?(event)
    if respond_to?(:notification_settings)
      key = "#{event.content_type.underscore}_#{event.event_type}"
      notification_settings.public_send(key.to_sym)
    else
      true
    end
  end

  def init
    self.joined ||= DateTime.current
    self.role   ||= :user
  end

  def create_associations
    create_reputation({ user_id: id })
    create_settings({ user_id: id })
    create_bio({ user_id: id })
  end

  def self.search_json(collection)
    collection.as_json({
        :only => [:id, :username]
    })
  end

  def current_json
    self.as_json({
        :only => [:id, :username, :role, :title],
        :include => {
            :reputation => {
                :only => [:overall, :rep_to_count]
            },
            :settings => {
                :only => [:theme, :show_notifications, :allow_adult_content]
            }
        },
        :methods => [:avatar, :recent_notifications]
    })
  end

  def settings_json
    self.as_json({
        :except => [:active_mod_list_id, :invitation_token, :invitation_created_at, :invitation_sent_at, :invitation_accepted_at, :invitation_limit, :invited_by_id, :invited_by_type, :invitations_count],
        :include => {
            :bio => {
                :except => [:user_id]
            },
            :reputation => {
                :except => [:user_id, :dont_compute]
            },
            :settings => {
                :except => [:user_id]
            }
        },
        :methods => :avatar
    })
  end

  def show_json(current_user)
    # email handling
    methods = [:avatar, :last_sign_in_at, :current_sign_in_at]
    if self.email_public?
      methods.push(:email)
    end

    self.as_json({
        :except => [:active_mod_list_id, :invitation_token, :invitation_created_at, :invitation_sent_at, :invitation_accepted_at, :invitation_limit, :invited_by_id, :invited_by_type, :invitations_count],
        :include => {
            :bio => {
                :except => [:user_id, :nexus_verification_token, :lover_verification_token, :workshop_verification_token]
            },
            :reputation => {
                :only => [:overall]
            }
        },
        :methods => methods
    })
  end

  def as_json(options={})
    if JsonHelpers.json_options_empty(options)
      default_options = {
          :except => [:active_mod_list_id, :invitation_token, :invitation_created_at, :invitation_sent_at, :invitation_accepted_at, :invitation_limit, :invited_by_id, :invited_by_type, :invitations_count],
          :methods => [:avatar, :last_sign_in_at, :current_sign_in_at],
          :include => {
              :reputation => {
                  :only => [:overall]
              }
          }
      }
      super(options.merge(default_options))
    else
      super(options)
    end
  end

  def notification_json_options(event_type)
    options = {
        :only => [:username, (:role if event_type == :status)].compact
    }
  end

  def self.sortable_columns
    {
        :only => [:username, :role, :title, :comments_count, :authored_mods_count, :submitted_mods_count, :reviews_count, :compatibility_notes_count, :install_order_notes_count, :load_order_notes_count, :corrections_count, :submitted_comments_count, :mod_lists_count, :mod_collections_count, :tags_count, :mod_tags_count, :mod_list_tags_count, :helpful_marks_count, :agreement_marks_count, :starred_mods_count, :starred_mod_lists_count, :mod_stars_count, :joined, :last_sign_in_at, :current_sign_in_at],
        :include => {
            :user_reputations => {
                :only => [:overall]
            }
        }
    }
  end
end
