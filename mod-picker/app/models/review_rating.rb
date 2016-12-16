class ReviewRating < ActiveRecord::Base
  include BetterJson

  belongs_to :review, :inverse_of => 'review_ratings'
  belongs_to :review_section, :inverse_of => 'review_ratings'

  # VALIDATIONS
  validates :review_section_id, presence: true
  validates :rating, inclusion: { in: 0..100, message: "Ratings must be between 0 and 100." }
  validate :section_uniqueness

  def section_uniqueness
    matching_sections = review.review_ratings.select do |rating|
      rating.review_section_id == review_section_id
    end
    if matching_sections.size > 1
      errors.add("You can only use a review section once per review.")
    end
  end
end