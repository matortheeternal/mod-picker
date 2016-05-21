class ReviewRating < EnhancedRecord::Base
  belongs_to :review, :inverse_of => 'review_ratings'
  belongs_to :review_section, :inverse_of => 'review_ratings'
end