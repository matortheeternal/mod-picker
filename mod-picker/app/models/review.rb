class Review < ActiveRecord::Base
  include Filterable, RecordEnhancements

  scope :game, -> (id) { where(game_id: id) }
  scope :user, -> (id) { where(submitted_by: id) }
  scope :mod, -> (mod) { where(mod_id: mod) }
  scope :submitted, -> (low, high) { where(submitted: parseDate(low)..parseDate(high)) }
  scope :edited, -> (low, high) { where(edited: parseDate(low)..parseDate(high)) }
  scope :hidden, -> (bool) { where(hidden: bool) }
  scope :approved, -> (bool) { where(approved: bool) }
  scope :helpful_count, -> (low, high) { where(helpful_count: low..high) }
  scope :not_helpful_count, -> (low, high) { where(not_helpful_count: low..high) }
  scope :ratings_count, -> (low, high) { where(ratings_count: low..high) }
  scope :overall_rating, -> (low, high) { where(overall_rating: low..high) }

  belongs_to :game, :inverse_of => 'reviews'
  belongs_to :user, :foreign_key => 'submitted_by', :inverse_of => 'reviews'
  belongs_to :mod, :inverse_of => 'reviews'

  has_many :review_ratings, :inverse_of => 'review', :dependent => :destroy

  has_many :helpful_marks, :as => 'helpfulable'
  has_one :base_report, :as => 'reportable'

  accepts_nested_attributes_for :review_ratings

  # Validations
  validates :mod_id, :text_body, presence: true
  validates :text_body, length: {in: 512..32768}

  # Callbacks
  after_create :increment_counters
  before_save :set_dates
  after_save :update_mod_metrics, :update_metrics
  before_destroy :decrement_counters

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

  def as_json(options={})
    if JsonHelpers.json_options_empty(options)
      default_options = {
          :include => {
              :review_ratings => {
                  :except => [:review_id]
              },
              :user => {
                  :only => [:id, :username, :role, :title],
                  :include => {
                      :reputation => {:only => [:overall]}
                  },
                  :methods => :avatar
              }
          }
      }
      super(options.merge(default_options))
    else
      super(options)
    end
  end

  def recompute_helpful_counts
    self.helpful_count = HelpfulMark.where(helpfulable_id: self.id, helpfulable_type: "Review", helpful: true).count
    self.not_helpful_count = HelpfulMark.where(helpfulable_id: self.id, helpfulable_type: "Review", helpful: false).count
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
      # we also take this chance to recompute the mod's reputation
      # if there are enough reviews to do so
      if self.mod.reviews_count >= 5
        self.mod.compute_reputation
      end
      self.mod.save
      self.user.update_counter(:reviews_count, 1)
    end

    def decrement_counters
      self.mod.reviews_count -= 1
      self.mod.compute_reputation
      self.mod.save
      self.user.update_counter(:reviews_count, -1)
    end
end
