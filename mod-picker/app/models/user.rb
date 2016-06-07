class User < ActiveRecord::Base
  include Filterable, RecordEnhancements

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  scope :search, -> (search) { joins(:bio).where("username like ? OR nexus_username like ? OR lover_username like ? OR steam_username like ?", "#{search}%", "#{search}%", "#{search}%", "#{search}%") }
  scope :joined, -> (low, high) { where(joined: (low..high)) }
  scope :last_seen, -> (low, high) { where(last_sign_in_at: (low..high)) }
  scope :level, -> (hash) { where(user_level: hash) }
  scope :rep, -> (low, high) { where(:reputation => {overall: (low..high)}) }
  scope :mods, -> (low, high) { where(mods_count: (low..high)) }
  scope :cnotes, -> (low, high) { where(compatibility_notes_count: (low..high)) }
  scope :inotes, -> (low, high) { where(installation_notes_count: (low..high)) }
  scope :reviews, -> (low, high) { where(reviews_count: (low..high)) }
  scope :nnotes, -> (low, high) { where(corrections_count: (low..high)) }
  scope :comments, -> (low, high) { where(comments_count: (low..high)) }
  scope :mod_lists, -> (low, high) { where(mod_lists_count: (low..high)) }

  attr_accessor :login

  has_one :settings, :class_name => 'UserSetting', :dependent => :destroy
  has_one :bio, :class_name => 'UserBio', :dependent => :destroy
  has_one :reputation, :class_name => 'UserReputation', :dependent => :destroy

  has_many :help_pages, :foreign_key => 'submitted_by', :inverse_of => 'user'
  has_many :comments, :foreign_key => 'submitted_by', :inverse_of => 'user'
  has_many :install_order_notes, :foreign_key => 'submitted_by', :inverse_of => 'user'
  has_many :load_order_notes, :foreign_key => 'submitted_by', :inverse_of => 'user'
  has_many :compatibility_notes, :foreign_key => 'submitted_by', :inverse_of => 'user'
  has_many :reviews, :foreign_key => 'submitted_by', :inverse_of => 'user'
  has_many :corrections, :foreign_key => 'submitted_by', :inverse_of => 'user'
  has_many :agreement_marks, :foreign_key => 'submitted_by', :inverse_of => 'user'
  has_many :helpful_marks, :foreign_key => 'submitted_by', :inverse_of => 'user'

  has_many :compatibility_note_history_entries, :foreign_key => 'submitted_by', :inverse_of => 'user'

  has_many :tags, :foreign_key => 'submitted_by', :inverse_of => 'user'
  has_many :mod_tags, :foreign_key => 'submitted_by', :inverse_of => 'user'
  has_many :mod_list_tags, :foreign_key => 'submitted_by', :inverse_of => 'user'

  has_many :submitted_mods, :class_name => 'Mod', :foreign_key => 'submitted_by', :inverse_of => 'user'

  has_many :mod_authors, :inverse_of => 'user'
  has_many :mods, :through => 'mod_authors', :inverse_of => 'author_users'
  has_many :mod_lists, :foreign_key => 'submitted_by', :inverse_of => 'user'

  belongs_to :active_mod_list, :class_name => 'ModList', :foreign_key => 'active_mod_list_id'

  has_many :mod_stars, :inverse_of => 'user'
  has_many :starred_mods, :through => 'mod_stars'

  has_many :mod_list_stars, :inverse_of => 'user'
  has_many :starred_mod_lists, :through => 'mod_list_stars'

  has_many :profile_comments, :class_name => 'Comment', :as => 'commentable'
  has_many :reports, :inverse_of => 'user'
  has_one :base_report, :as => 'reportable'

  accepts_nested_attributes_for :settings
  accepts_nested_attributes_for :bio

  # Validations
  validates :username, presence: true, uniqueness: { case_sensitive: false }, length: {in: 4..20 }

  # TODO: add email regex
  # basic one, minimize false negatives and confirm users via email confirmation regardless
  validates :email, presence: true, uniqueness: { case_sensitive: false }, length: {in: 7..254}
  # format: {
  # with: VALID_EMAIL_REGEX,
  # message: must be a valid email address format
  # }
  
  validates :role, presence: true
  validates :about_me, length: {maximum: 16384}
  validate :validate_username

  # Callbacks
  after_create :create_associations
  after_initialize :init

  def validate_username
    if User.where(email: username).exists?
      errors.add(:username, :invalid)
    end
  end

  def avatar
    png_path = File.join(Rails.public_path, "avatars/#{id}.png")
    jpg_path = File.join(Rails.public_path, "avatars/#{id}.jpg")
    if File.exists?(png_path)
      "/avatars/#{id}.png"
    elsif File.exists?(jpg_path)
      "/avatars/#{id}.jpg"
    elsif self.title.nil?
      nil
    else
      '/avatars/Default.png'
    end
  end

  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
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
    self.role.to_sym == :admin
  end

  def moderator?
    self.role.to_sym == :moderator
  end

  def can_moderate?
    self.admin? || self.moderator?
  end

  def banned?
    self.role.to_sym == :banned
  end

  def inactive?
    self.last_sign_in_at < 28.days.ago
  end

  def email_public?
    self.settings.email_public
  end

  def init
    self.joined ||= DateTime.current
    self.role   ||= :user
  end

  def create_associations
    self.create_reputation({ user_id: self.id })
    self.create_settings({ user_id: self.id })
    self.create_bio({ user_id: self.id })
  end

  def current_json
    self.as_json({
        :only => [:id, :username, :role, :title, :active_mod_list_id],
        :include => {
            :reputation => {
                :only => [:overall]
            },
            :settings => {
                :except => [:user_id]
            },
            :active_mod_list => {
                :only => [:id, :name, :mods_count, :plugins_count, :active_plugins_count, :custom_plugins_count],
                :methods => [:incompatible_mods]
            }
        },
        :methods => :avatar
    })
  end

  def show_json(current_user)
    # email handling
    methods = [:avatar, :last_sign_in_at, :current_sign_in_at, :email_public?]
    bio_except = [:nexus_verification_token, :lover_verification_token, :workshop_verification_token]
    if self.email_public? || current_user.id == self.id
      methods.push(:email)
    end
    if current_user.id == self.id
      bio_except = [:user_id]
    end

    self.as_json({
        :except => [:active_mod_list_id, :invitation_token, :invitation_created_at, :invitation_sent_at, :invitation_accepted_at, :invitation_limit, :invited_by_id, :invited_by_type, :invitations_count],
        :include => {
            :mods => {
                :only => [:id, :name, :game_id, :mod_stars_count]
            },
            :mod_lists => {
                :only => [:id, :name, :is_collection, :is_public, :status, :mods_count, :created]
            },
            :bio => {
                :except => bio_except
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
end
