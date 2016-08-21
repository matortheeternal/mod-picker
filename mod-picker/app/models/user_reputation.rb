class UserReputation < ActiveRecord::Base
  include Filterable, RecordEnhancements

  scope :user, -> (id) { where(user_id: id) }

  belongs_to :user

  has_many :received_reputation, :class_name => 'ReputationLink', :inverse_of => 'target_reputation', :dependent => :destroy
  has_many :given_reputation, :class_name => 'ReputationLink', :inverse_of => 'source_reputation', :dependent => :destroy

  # Validations
  validates :user_id, presence: true

  # CONSTANTS
  # site reputation
  MP_ACCOUNT_AGE_RATIO = 0.01
  SITE_ACCOUNT_AGE_RATIO = 0.005
  SITE_POST_RATIO = 0.004
  WORKSHOP_SUBMISSIONS_RATIO = 0.1
  WORKSHOP_FOLLOWERS_RATIO = 0.005
  MAX_SITE_REP = 50

  def calculate_site_rep
    # MOD PICKER
    mp_account_age = (Date.now - self.user.joined)
    self.site_rep += mp_account_age * MP_ACCOUNT_AGE_RATIO

    # NEXUS MODS
    if self.user.bio.nexus_user_path.present?
      nexus_account_age = (Date.now - self.user.bio.nexus_date_joined)
      self.site_rep += nexus_account_age * SITE_ACCOUNT_AGE_RATIO
      self.site_rep += self.user.bio.nexus_posts_count * SITE_POST_RATIO
    end

    # LOVER'S LAB
    if self.user.bio.lover_user_path.present?
      lover_account_age = (Date.now - self.user.bio.lover_date_joined)
      self.site_rep += lover_account_age * SITE_ACCOUNT_AGE_RATIO
      self.site_rep += self.user.bio.lover_posts_count * SITE_POST_RATIO
    end

    # STEAM WORKSHOP
    if self.user.bio.workshop_user_path.present?
      self.site_rep += self.user.bio.workshop_submissions_count * WORKSHOP_SUBMISSIONS_RATIO
      self.site_rep += self.user.bio.workshop_followers_count * WORKSHOP_FOLLOWERS_RATIO
    end

    # Cap at MAX_SITE_REP
    self.site_rep = [self.site_rep, MAX_SITE_REP].max
  end
end
