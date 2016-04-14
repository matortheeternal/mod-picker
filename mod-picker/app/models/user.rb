class User < ActiveRecord::Base
  include Filterable

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
  scope :nnotes, -> (low, high) { where(incorrect_notes_count: (low..high)) }
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
  has_many :incorrect_notes, :foreign_key => 'submitted_by', :inverse_of => 'user'
  has_many :agreement_marks, :foreign_key => 'submitted_by', :inverse_of => 'user'
  has_many :helpful_marks, :foreign_key => 'submitted_by', :inverse_of => 'user'
  has_many :compatibility_note_history_entries, :foreign_key => 'submitted_by', :inverse_of => 'user'

  has_many :mod_authors, :inverse_of => 'user'
  has_many :mods, :through => 'mod_authors', :inverse_of => 'authors'
  has_many :mod_lists, :foreign_key => 'created_by', :inverse_of => 'user'

  belongs_to :active_mod_list, :class_name => 'ModList', :foreign_key => 'active_mod_list_id'

  has_many :mod_stars, :inverse_of => 'user'
  has_many :starred_mods, :through => 'mod_stars', :inverse_of => 'user_stars'

  has_many :mod_list_stars, :inverse_of => 'user_star'
  has_many :starred_mod_lists, :through => 'mod_list_stars', :inverse_of => 'user_stars'

  has_many :profile_comments, :class_name => 'Comment', :as => 'commentable'

  accepts_nested_attributes_for :settings
  accepts_nested_attributes_for :bio

  after_create :create_associations
  after_initialize :init

  validates :username,
  presence: true,
  uniqueness: {
    case_sensitive: false
  },
  length: 4..20

  # TODO: add email regex
  # basic one, minimize false negatives and confirm users via email confirmation regardless
  validates :email,
  presence: true,
  uniqueness: {
    case_sensitive: false
  },
  length: 7..100
  # format: {
  # with: VALID_EMAIL_REGEX,
  # message: must be a valid email address format
  # }
  
  validate :validate_username

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

  def banned?
    self.role.to_sym == :banned
  end

  def inactive?
    self.last_sign_in_at < 28.days.ago
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

  def as_json(options={})
    default_options = {
        :except => [:email, :active_mod_list_id, :invitation_token, :invitation_created_at, :invitation_sent_at, :invitation_accepted_at, :invitation_limit, :invited_by_id, :invited_by_type, :invitations_count],
        :methods => :avatar,
        :include => {
            :bio => {
                :only => [:nexus_username, :lover_username, :steam_username]
            },
            :reputation => {
                :only => [:overall]
            }
        }
    }
    options = default_options.merge(options)
    super(options)
  end
end
