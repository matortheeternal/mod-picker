class ReviewRating < ActiveRecord::Base
  belongs_to :review, :inverse_of => 'review_ratings'
  belongs_to :review_section, :inverse_of => 'review_ratings'

  # Validations
  validates :review_section_id, :rating, presence: true
  validates :rating, numericality: { only_integer: true }
  validates :rating, inclusion: { in: 0..100, message: "Ratings must be between 0 and 100." }
  validates :review_section_id, :uniqueness => { scope: :review_id, message: "You can only use a review section once per review."}
end