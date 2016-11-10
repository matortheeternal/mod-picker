class ReviewSection < ActiveRecord::Base
  include BetterJson

  belongs_to :category, :inverse_of => 'review_sections'
  has_many :review_ratings, :inverse_of => 'review_section'

  # VALIDATIONS
  validates :category_id, :name, :prompt, presence: true
  validates :name, length: { maximum: 32 }
  validates :prompt, length: { maximum: 255 }
  validates :default, inclusion: [true, false]
end