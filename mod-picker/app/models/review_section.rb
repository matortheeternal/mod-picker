class ReviewSection < EnhancedRecord::Base
  belongs_to :category, :inverse_of => 'review_sections'
  has_many :review_ratings, :inverse_of => 'review_section'
end