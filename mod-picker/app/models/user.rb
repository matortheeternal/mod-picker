class User < ActiveRecord::Base
  include Filterable, Sortable, RecordEnhancements, Reportable

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  attr_accessor :login

  # GENERAL SCOPES
  scope :search, -> (search) { where("username like ?", "#{search}%") }
  scope :linked, -> (search) { joins(:bio).where("nexus_username like ? OR lover_username like ? OR workshop_username like ?", "#{search}%", "#{search}%", "#{search}%") }
  scope :roles, -> (roles_hash) {
    # build roles array
    roles = []
    roles_hash.each_key do |key|
      if roles_hash[key]
        roles.push(key)
      end
    end

    # return query
    where(role: roles)
  }
  scope :reputation, -> (range) { joins(:reputation).where(:user_reputations => {:overall => range[:min]..range[:max]}) }
  scope :joined, -> (range) { where(joined: parseDate(range[:min])..parseDate(range[:max])) }
  scope :last_seen, -> (range) { where(last_sign_in_at: parseDate(range[:min])..parseDate(range[:max])) }
  # STATISTIC SCOPES
  scope :authored_mods, -> (range) { where(authored_mods_count: range[:min]..range[:max]) }
  scope :mod_lists, -> (range) { where(mod_lists_count: range[:min]..range[:max]) }
  scope :comments, -> (range) { where(comments_count: range[:min]..range[:max]) }
  scope :reviews, -> (range) { where(reviews_count: range[:min]..range[:max]) }
  scope :compatibility_notes, -> (range) { where(compatibility_notes_count: range[:min]..range[:max]) }
  scope :install_order_notes, -> (range) { where(install_order_notes_count: range[:min]..range[:max]) }
  scope :load_order_notes, -> (range) { where(load_order_notes_count: range[:min]..range[:max]) }
  scope :corrections, -> (range) { where(corrections_count: range[:min]..range[:max]) }

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
  has_many :starred_mods, :through => 'mod_stars'

  has_many :mod_list_stars, :inverse_of => 'user'
  has_many :starred_mod_lists, :through => 'mod_list_stars'

  has_many :profile_comments, -> { where(parent_id: nil) }, :class_name => 'Comment', :as => 'commentable'
  has_many :reports, :foreign_key => 'submitted_by', :inverse_of => 'submitter'

  accepts_nested_attributes_for :settings
  accepts_nested_attributes_for :bio

  # number of users per page on the users index
  self.per_page = 50

  # Validations
  validates :username, :email, :role, presence: true
  validates :username, uniqueness: { case_sensitive: false }, length: {in: 4..32 }

  # TODO: add email regex
  # basic one, minimize false negatives and confirm users via email confirmation regardless
  validates :email, uniqueness: { case_sensitive: false }, length: {in: 7..255}

  validates :about_me, length: {maximum: 16384}

  # Callbacks
  after_create :create_associations
  after_initialize :init

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
    self.last_sign_in_at.nil? || self.last_sign_in_at < 28.days.ago
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
                :only => [:id, :name, :game_id, :stars_count, :reviews_count, :reputation]
            },
            :mod_lists => {
                :only => [:id, :name, :is_collection, :is_public, :status, :mods_count, :created, :stars_count, :comments_count]
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
