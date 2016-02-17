class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable
  
  attr_accessor :login

  has_one :settings, :class_name => 'UserSetting', :dependent => :destroy
  has_one :bio, :class_name => 'UserBio', :dependent => :destroy
  has_one :reputation, :class_name => 'UserReputation', :dependent => :destroy

  has_many :comments, :foreign_key => 'submitted_by', :inverse_of => 'user'
  has_many :installation_notes, :foreign_key => 'submitted_by', :inverse_of => 'user'
  has_many :compatibility_notes, :foreign_key => 'submitted_by', :inverse_of => 'user'
  has_many :reviews, :foreign_key => 'submitted_by', :inverse_of => 'user'
  has_many :incorrect_notes, :foreign_key => 'submitted_by', :inverse_of => 'user'
  has_many :agreement_marks, :foreign_key => 'submitted_by', :inverse_of => 'user'

  has_many :mod_authors, :inverse_of => 'user'
  has_many :mods, :through => 'mod_authors', :inverse_of => 'authors'
  has_many :mod_lists, :foreign_key => 'created_by', :inverse_of => 'user'

  belongs_to :active_mod_list, :class_name => 'ModList', :foreign_key => 'active_ml_id'
  belongs_to :active_mod_collection, :class_name => 'ModList', :foreign_key => 'active_mc_id'

  has_many :mod_stars, :inverse_of => 'user_star'
  has_many :starred_mods, :through => 'mod_stars', :inverse_of => 'user_stars', :counter_cache => true

  has_many :mod_list_stars, :inverse_of => 'user_star'
  has_many :starred_mod_lists, :through => 'mod_list_stars', :inverse_of => 'user_stars'

  has_many :profile_comments, :class_name => 'Comment', :as => 'commentable'

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
    self.joined     ||= DateTime.current
    self.title      ||= 'Prisoner'
    self.avatar     ||= 'NewUser.png'
    self.user_level ||= :user
  end
  
  def create_associations
    self.create_reputation({ user_id: self.id })
    self.create_settings({ user_id: self.id })
    self.create_bio({ user_id: self.id })
  end

  def as_json(options={})
    options[:except] ||= [:email, :active_ml_id, :active_mc_id]
    options[:include] ||= {
        :bio => {:only => [:nexus_username, :steam_username]},
        :reputation => {:only => [:overall, :offset]}
    }
    super(options)
  end
end
