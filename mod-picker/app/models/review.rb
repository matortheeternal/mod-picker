class Review < EnhancedRecord::Base
  include Filterable

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
  validates :review_template_id, :mod_id, :rating1, :text_body, presence: true
  validates :hidden, inclusion: [true, false]
  validates :rating1, :rating2, :rating3, :rating4, :rating5, length: {in: 0..100}
  validates :text_body, length: {in: 255..32768}

  # Callbacks
  after_create :increment_counter_caches
  before_save :set_dates
  before_destroy :decrement_counter_caches

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

    def increment_counter_caches
      self.mod.reviews_count += 1
      # we also take this chance to recompute the mod's reputation
      # if there are enough reviews to do so
      if self.mod.reviews_count >= 5
        self.mod.compute_reputation
      end
      self.mod.save
    end

    def decrement_counter_caches
      self.mod.reviews_count -= 1
      self.mod.save
    end
end
