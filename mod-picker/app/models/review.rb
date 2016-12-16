class Review < ActiveRecord::Base
  include Filterable, Sortable, RecordEnhancements, CounterCache, Helpfulable, Reportable, Approveable, ScopeHelpers, Trackable, BetterJson, Dateable

  # ATTRIBUTES
  self.per_page = 25

  # DATE COLUMNS
  date_column :submitted, :edited

  # EVENT TRACKING
  track :added, :approved, :hidden
  track :message, :column => 'moderator_message'

  # NOTIFICATION SUBSCRIPTION
  subscribe :mod_author_users, to: [:added, :approved, :unhidden]
  subscribe :submitter, to: [:message, :approved, :unapproved, :hidden, :unhidden]

  # SCOPES
  hash_scope :approved, alias: 'approved'
  hash_scope :hidden, alias: 'hidden'
  hash_scope :adult, alias: 'adult', column: 'has_adult_content'
  include_scope :hidden
  visible_scope :approvable => true
  game_scope
  search_scope :text_body, :alias => 'search'
  user_scope :submitter, :editor
  range_scope :overall, :association => 'submitter_reputation', :table => 'user_reputations', :alias => 'reputation'
  range_scope :overall_rating, :ratings_count
  date_scope :submitted, :edited

  # ASSOCIATIONS
  belongs_to :game, :inverse_of => 'reviews'
  belongs_to :submitter, :class_name => 'User', :foreign_key => 'submitted_by', :inverse_of => 'reviews'
  belongs_to :editor, :class_name => 'User', :foreign_key => 'edited_by'
  belongs_to :mod, :inverse_of => 'reviews'
  has_many :review_ratings, :inverse_of => 'review'

  # ASSOCIATIONS FOR SUBSCRIPTIONS
  has_one :submitter_reputation, :class_name => 'UserReputation', :through => 'submitter', :source => 'reputation'
  has_many :mod_author_users, :through => :mod, :source => :author_users

  # NESTED ATTRIBUTES
  accepts_nested_attributes_for :review_ratings

  # COUNTER CACHE
  counter_cache_on :mod, :submitter, conditional: { hidden: false, approved: true }

  # VALIDATIONS
  validates :game_id, :submitted_by, :mod_id, :text_body, presence: true
  validates :text_body, length: {in: 512..32768}
  # only one review per mod per user
  validates :mod_id, uniqueness: { scope: :submitted_by, :message => "You've already submitted a review for this mod." }
  validate :not_mod_author
  validate :number_of_ratings
  validates_associated :review_ratings

  # CALLBACKS
  before_save :set_adult
  after_save :update_metrics
  before_destroy :clear_ratings
  after_destroy :update_mod_review_metrics

  def number_of_ratings
    num_ratings = review_ratings.length
    if num_ratings == 0
      errors.add(:review_ratings, "A review must have at least 1 rating section.")
    elsif num_ratings > 5
      errors.add(:review_ratings, "A review cannot have more than 5 rating sections.")
    end
  end

  def not_mod_author
    is_author = ModAuthor.where(mod_id: mod_id, role: [0, 1]).exists?
    if is_author
      errors.add(:mod, "You cannot submit reviews for mods you an author or contributor for.")
    end
  end

  def clear_ratings
    ReviewRating.where(review_id: id).delete_all
  end

  def update_metrics
    compute_overall_rating
    save_columns!(:overall_rating, :ratings_count)
    update_mod_review_metrics
  end

  def update_mod_review_metrics
    mod.update_review_metrics
  end

  def compute_overall_rating
    total = review_ratings.reduce(0) {|total, r| total += r.rating}
    self.ratings_count = review_ratings.length
    self.overall_rating = (total.to_f / self.ratings_count) if self.ratings_count > 0
  end

  private
    def set_adult
      self.has_adult_content = mod.has_adult_content
      true
    end
end