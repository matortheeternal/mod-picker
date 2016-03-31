class User < ActiveRecord::Base
  include Filterable

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
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

  has_many :comments, :foreign_key => 'submitted_by', :inverse_of => 'user'
  has_many :install_order_notes, :foreign_key => 'submitted_by', :inverse_of => 'user'
  has_many :load_order_notes, :foreign_key => 'submitted_by', :inverse_of => 'user'
  has_many :compatibility_notes, :foreign_key => 'submitted_by', :inverse_of => 'user'
  has_many :reviews, :foreign_key => 'submitted_by', :inverse_of => 'user'
  has_many :incorrect_notes, :foreign_key => 'submitted_by', :inverse_of => 'user'
  has_many :agreement_marks, :foreign_key => 'submitted_by', :inverse_of => 'user'

  has_many :mod_authors, :inverse_of => 'user'
  has_many :mods, :through => 'mod_authors', :inverse_of => 'authors'
  has_many :mod_lists, :foreign_key => 'created_by', :inverse_of => 'user'

  belongs_to :active_mod_list, :class_name => 'ModList', :foreign_key => 'active_mod_list_id'

  has_many :mod_stars, :inverse_of => 'user_star'
  has_many :starred_mods, :through => 'mod_stars', :inverse_of => 'user_stars'

  has_many :mod_list_stars, :inverse_of => 'user_star'
  has_many :starred_mod_lists, :through => 'mod_list_stars', :inverse_of => 'user_stars'

  has_many :profile_comments, :class_name => 'Comment', :as => 'commentable'

  accepts_nested_attributes_for :settings
  accepts_nested_attributes_for :bio

  after_create :create_associations
  after_initialize :init

  validates :username,
  :presence => true,
  :uniqueness => {
    :case_sensitive => false
  }

  validate :validate_username

  def validate_username
    if User.where(email: username).exists?
      errors.add(:username, :invalid)
    end
  end

  def user_avatar
    if File.exists?(File.join(Rails.public_path, "avatars/#{id}.png"))
      "/avatars/#{id}.png"
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
    options[:except] ||= [:email, :active_ml_id, :active_mc_id]
    options[:include] ||= {
        :bio => {:only => [:nexus_username, :lover_username, :steam_username]},
        :reputation => {:only => [:overall]}
    }
    super(options).merge({
        :avatar => user_avatar
    })
  end
end
