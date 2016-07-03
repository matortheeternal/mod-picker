class Review < ActiveRecord::Base
  include Filterable, Sortable, RecordEnhancements

  # GENERAL SCOPES
  scope :visible, -> { where(hidden: false, approved: true) }
  scope :game, -> (game_id) { where(game_id: game_id) }
  scope :user, -> (user_id) { where(submitted_by: user_id) }
  scope :mod, -> (mod) { where(mod_id: mod) }
  scope :submitted, -> (low, high) { where(submitted: parseDate(low)..parseDate(high)) }
  scope :edited, -> (low, high) { where(edited: parseDate(low)..parseDate(high)) }
  scope :helpful_count, -> (low, high) { where(helpful_count: low..high) }
  scope :not_helpful_count, -> (low, high) { where(not_helpful_count: low..high) }
  scope :ratings_count, -> (low, high) { where(ratings_count: low..high) }
  scope :overall_rating, -> (low, high) { where(overall_rating: low..high) }

  belongs_to :game, :inverse_of => 'reviews'
  belongs_to :submitter, :class_name => 'User', :foreign_key => 'submitted_by', :inverse_of => 'reviews'
  belongs_to :editor, :class_name => 'User', :foreign_key => 'edited_by'
  belongs_to :mod, :inverse_of => 'reviews'

  has_many :review_ratings, :inverse_of => 'review'

  has_many :helpful_marks, :as => 'helpfulable'
  has_one :base_report, :as => 'reportable'

  accepts_nested_attributes_for :review_ratings

  self.per_page = 25

  # Validations
  validates :game_id, :submitted_by, :mod_id, :text_body, presence: true
  validates :text_body, length: {in: 512..32768}
  # only one review per mod per user
  validates :mod_id, uniqueness: { scope: :submitted_by, :message => "You've already submitted a review for this mod." }

  # Callbacks
  after_create :increment_counters
  before_save :set_dates
  after_save :update_mod_metrics, :update_metrics
  before_destroy :clear_ratings, :decrement_counters

  def clear_ratings
    ReviewRating.where(review_id: self.id).delete_all
  end

  def update_metrics
    compute_overall_rating
    self.update_columns({
      ratings_count: self.review_ratings.count,
      overall_rating: self.overall_rating
    })
  end

  def update_mod_metrics
    self.mod.compute_average_rating
    self.mod.compute_reputation
    self.mod.save
  end

  def compute_overall_rating
    total = 0
    count = 0

    self.review_ratings.each do |r|
      total += r.rating
      count += 1
    end

    self.overall_rating = (total.to_f / count) if count > 0
  end

  def compute_reputation
    # TODO: We could base this off of the reputation of the people who marked the review helpful/not helpful, but we aren't doing that yet
    user_rep = self.submitter.reputation.overall
    helpfulness = (self.helpful_count - self.not_helpful_count)
    if user_rep < 0
      self.reputation = user_rep + helpfulness
    else
      user_rep_factor = 2 / (1 + Math::exp(-0.0075 * (user_rep - 640)))
      if self.helpful_count < self.not_helpful_count
        self.reputation = (1 - user_rep_factor / 2) * helpfulness
      else
        self.reputation = (1 + user_rep_factor) * helpfulness
      end
    end
  end

  def recompute_helpful_counts
    self.helpful_count = HelpfulMark.where(helpfulable_id: self.id, helpfulable_type: "Review", helpful: true).count
    self.not_helpful_count = HelpfulMark.where(helpfulable_id: self.id, helpfulable_type: "Review", helpful: false).count
  end

  def as_json(options={})
    if JsonHelpers.json_options_empty(options)
      default_options = {
          :include => {
              :review_ratings => {
                  :except => [:review_id]
              },
              :submitter => {
                  :only => [:id, :username, :role, :title],
                  :include => {
                      :reputation => {:only => [:overall]}
                  },
                  :methods => :avatar
              },
              :editor => {
                  :only => [:id, :username, :role]
              }
          }
      }
      super(options.merge(default_options))
    else
      super(options)
    end
  end

  private
    def set_dates
      if self.submitted.nil?
        self.submitted = DateTime.now
      else
        self.edited = DateTime.now
      end
    end

    def increment_counters
      self.mod.reviews_count += 1
      self.mod.compute_average_rating
      # we also take this chance to recompute the mod's reputation
      # if there are enough reviews to do so
      if self.mod.reviews_count >= 5
        self.mod.compute_reputation
      end
      self.mod.save
      self.submitter.update_counter(:reviews_count, 1)
    end

    def decrement_counters
      self.mod.reviews_count -= 1
      self.mod.compute_average_rating
      self.mod.compute_reputation
      self.mod.save
      self.submitter.update_counter(:reviews_count, -1)
    end
end
