class ReviewRating < ActiveRecord::Base
  belongs_to :review, :inverse_of => 'review_ratings'
  belongs_to :review_section, :inverse_of => 'review_ratings'

  # Callbacks
  after_create :increment_counter_caches
  before_destroy :decrement_counter_caches

  # Private methods
  private
    def increment_counter_caches
      self.review.update_counter(:ratings_count, 1)
    end

    def decrement_counter_caches
      self.review.update_counter(:ratings_count, -1)
    end
end