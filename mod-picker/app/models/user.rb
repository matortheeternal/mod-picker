class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable
  
  attr_accessor :login
  has_one :settings, :foreign_key => "set_id", :class_name => "UserSetting", :dependent => :destroy
  has_one :bio, :foreign_key => "bio_id", :class_name => "UserBio", :dependent => :destroy
  has_one :reputation, :foreign_key => "rep_id", :class_name => "UserReputation", :dependent => :destroy
  after_create :init
  
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
    self.create_reputation({ user_id: self.user_id })
    self.create_settings({ user_id: self.user_id })
    self.create_bio({ user_id: self.user_id })
  end
end
