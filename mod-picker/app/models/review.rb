class Review < ActiveRecord::Base
  include Filterable, Sortable, RecordEnhancements, Helpfulable, Reportable, Approveable, ScopeHelpers, Trackable, BetterJson, Dateable

  # ATTRIBUTES
  self.per_page = 25

  # EVENT TRACKING
  track :added, :approved, :hidden
  track :message, :column => 'moderator_message'

  # NOTIFICATION SUBSCRIPTION
  subscribe :mod_author_users, to: [:added, :approved, :unhidden]
  subscribe :submitter, to: [:message, :approved, :unapproved, :hidden, :unhidden]

  # SCOPES
  include_scope :hidden
  include_scope :has_adult_content, :alias => 'include_adult'
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

  accepts_nested_attributes_for :review_ratings

  # DATE COLUMNS
  date_column :submitted, :edited

  # VALIDATIONS
  validates :game_id, :submitted_by, :mod_id, :text_body, presence: true
  validates :text_body, length: {in: 512..32768}
  # only one review per mod per user
  validates :mod_id, uniqueness: { scope: :submitted_by, :message => "You've already submitted a review for this mod." }
  validate :not_mod_author
  validates_associated :review_ratings

  # CALLBACKS
  after_create :increment_counters
  before_save :set_adult, :set_dates
  after_save :update_metrics
  before_destroy :clear_ratings, :decrement_counters
  after_destroy :update_mod_metrics

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
    update_columns({
      ratings_count: review_ratings.count,
      overall_rating: overall_rating
    })
    update_mod_metrics
  end

  def update_mod_metrics
    mod.compute_average_rating
    mod.compute_reputation
    mod.update_columns({
        :reviews_count => mod.reviews_count,
        :reputation => mod.reputation,
        :average_rating => mod.average_rating
    })
  end

  def compute_overall_rating
    total = 0
    count = 0

    review_ratings.each do |r|
      total += r.rating
      count += 1
    end

    self.overall_rating = (total.to_f / count) if count > 0
  end

  def self.sortable_columns
    {
        :except => [:game_id, :submitted_by, :edited_by, :mod_id, :text_body, :edit_summary, :moderator_message],
        :include => {
            :submitter => {
                :only => [:username],
                :include => {
                    :reputation => {
                        :only => [:overall]
                    }
                }
            }
        }
    }
  end

  private
    def set_adult
      self.has_adult_content = mod.has_adult_content
      true
    end

    def increment_counters
      mod.update_counter(:reviews_count, 1)
      submitter.update_counter(:reviews_count, 1)
    end

    def decrement_counters
      mod.update_counter(:reviews_count, -1)
      submitter.update_counter(:reviews_count, -1)
    end
end
