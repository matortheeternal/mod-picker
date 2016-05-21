class Review < ActiveRecord::Base
  include Filterable, CounterCacheEnhancements

  scope :mod, -> (mod) { where(mod_id: mod) }
  scope :by, -> (id) { where(submitted_by: id) }

  belongs_to :game, :inverse_of => 'reviews'
  belongs_to :user, :foreign_key => 'submitted_by', :inverse_of => 'reviews'
  belongs_to :mod, :inverse_of => 'reviews'

  has_many :review_ratings, :inverse_of => 'review'

  has_many :helpful_marks, :as => 'helpfulable'
  has_one :base_report, :as => 'reportable'

  accepts_nested_attributes_for :review_ratings

  # Validations
  validates :mod_id, :text_body, presence: true
  validates :text_body, length: {in: 512..32768}

  # Callbacks
  after_create :increment_counters
  before_save :set_dates
  before_update :clear_associated
  after_update :update_lazy_counters
  before_destroy :decrement_counters

  def clear_associated
    ReviewRating.where(review_id: self.id).delete_all
  end

  def update_lazy_counters
    self.ratings_count = self.review_ratings.count
  end

  def overall_rating
    total = 0
    count = 0
    self.review_ratings.each do |r|
      total += r.rating
      count += 1
    end
    if count > 0
      (total.to_f / count)
    else
      100.0
    end
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
          },
          :methods => :overall_rating
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
