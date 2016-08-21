class UserReputation < ActiveRecord::Base
  include Filterable, RecordEnhancements

  attr_accessor :calc_rep

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

  # contribution reputation
  REVIEW_BASE_REP = 2
  REVIEW_HELPFUL_RATIO = 0.1
  CNOTE_BASE_REP = 1
  CNOTE_HELPFUL_RATIO = 0.05
  INOTE_BASE_REP = 1
  INOTE_HELPFUL_RATIO = 0.05
  LNOTE_BASE_REP = 1
  LNOTE_HELPFUL_RATIO = 0.05
  OPEN_CORRECTION_REP = 1
  CLOSED_CORRECTION_REP = 3
  NEW_TAG_REP = 0.2
  MOD_TAG_REP = 0.1
  MOD_LIST_TAG_REP = 0.05

  # author reputation
  AUTHOR_MAX = 1.0
  AUTHOR_OFFSET = 0.5
  AUTHOR_RANGE = 5
  CONTRIBUTOR_MAX = 0.3
  CONTRIBUTOR_OFFSET = 0.25
  CONTRIBUTOR_RANGE = 100
  CURATOR_BASE_REP = 5
  MAX_CURATOR_REP = 100

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

  def calculate_contribution_rep
    def get_contribution_rep(h, base, ratio)
      base + [-base, (h[0] - h[1]) * ratio, base].sort[1]
    end

    # REVIEWS
    reviews = self.user.reviews.visible
    reviews.pluck(:helpful_count, :not_helpful_count).each do |h|
      self.contribution_rep += get_contribution_rep(h, REVIEW_BASE_REP, REVIEW_HELPFUL_RATIO)
    end

    # COMPATIBILITY NOTES
    compatibility_notes = self.user.compatibility_notes.visible.standing([0])
    compatibility_notes.pluck(:helpful_count, :not_helpful_count).each do |h|
      self.contribution_rep += get_contribution_rep(h, CNOTE_BASE_REP, CNOTE_HELPFUL_RATIO)
    end

    # INSTALL ORDER NOTES
    install_order_notes = self.user.install_order_notes.visible.standing([0])
    install_order_notes.pluck(:helpful_count, :not_helpful_count).each do |h|
      self.contribution_rep += get_contribution_rep(h, INOTE_BASE_REP, INOTE_HELPFUL_RATIO)
    end

    # LOAD ORDER NOTES
    load_order_notes = self.user.load_order_notes.visible.standing([0])
    load_order_notes.pluck(:helpful_count, :not_helpful_count).each do |h|
      self.contribution_rep += get_contribution_rep(h, LNOTE_BASE_REP, LNOTE_HELPFUL_RATIO)
    end

    # CORRECTIONS
    open_corrections_count = self.user.corrections.visible.status([0]).count
    closed_corrections_count = self.user.corrections.visible.status([1, 3]).count
    self.contribution_rep += open_corrections_count * OPEN_CORRECTION_REP
    self.contribution_rep += closed_corrections_count * CLOSED_CORRECTION_REP

    # TAGS
    self.contribution_rep += self.user.tags_count * NEW_TAG_REP
    self.contribution_rep += self.user.mod_tags_count * MOD_TAG_REP
    self.contribution_rep += self.user.mod_list_tags_count * MOD_LIST_TAG_REP
  end

  def calculate_author_rep
    curator_rep = 0
    self.user.mod_authors.each do |ma|
      if ma.role == :author
        authors_count = ModAuthor.where(mod_id: ma.mod_id, role: 0).count
        percentage = AUTHOR_MAX - AUTHOR_OFFSET * (authors_count / AUTHOR_RANGE)
        self.author_rep += percentage * ma.mod.reputation
      elsif ma.role == :contributor
        contributors_count = ModAuthor.where(mod_id: ma.mod_id, role: 1).count
        percentage = CONTRIBUTOR_MAX - CONTRIBUTOR_OFFSET * (contributors_count / CONTRIBUTOR_RANGE)
        self.author_rep += percentage * ma.mod.reputation
      else # curator
        curator_rep += CURATOR_BASE_REP
      end
    end

    self.author_rep += [curator_rep, MAX_CURATOR_REP].max
  end

  def prepare_for_traversal
    self.calc_rep = self.offset + self.site_rep + self.contribution_rep + self.author_rep
  end

  def update_site_rep
    starting_site_rep = self.site_rep
    self.calculate_site_rep
    site_rep_diff = starting_site_rep - self.site_rep
    self.overall += site_rep_diff
  end

  def update_author_rep
    starting_author_rep = self.author_rep
    self.calculate_author_rep
    author_rep_diff = starting_author_rep - self.author_rep
    self.overall += author_rep_diff
  end
end
