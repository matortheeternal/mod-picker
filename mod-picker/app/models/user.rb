class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable
  
  attr_accessor :login

  has_one :settings, :class_name => 'UserSetting', :dependent => :destroy
  has_one :bio, :class_name => 'UserBio', :dependent => :destroy
  has_one :reputation, :class_name => 'UserReputation', :dependent => :destroy
  has_one :active_mod_list, :class_name => 'ModList'
  has_one :active_mod_collection, :class_name => 'ModList'
  has_many :comments
  has_many :installation_notes
  has_many :compatibility_notes
  has_many :reviews
  has_many :incorrect_notes
  has_many :agreement_marks, :foreign_key => 'submitted_by', :inverse_of => 'user'
  has_many :mods, :through => 'user_mod_author_map'
  has_many :mod_lists
  has_many :starred_mods, :class_name => 'Mod', :through => 'user_mod_star_map'
  has_many :starred_mod_lists, :class_name => 'ModList', :through => 'user_mod_list_star_map'
  has_many :profile_comments, :class_name => 'Comment', :as => 'commentable', :through => 'user_comments'

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
    self.create_reputation({ user_id: self.user_id })
    self.create_settings({ user_id: self.user_id })
    self.create_bio({ user_id: self.user_id })
  end
end
