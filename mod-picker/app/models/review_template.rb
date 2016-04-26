class ReviewTemplate < ActiveRecord::Base
  belongs_to :user, :foreign_key => 'submitted_by', :inverse_of => 'reviews'
  has_many :reviews, :inverse_of => 'review_template'

  # Validations
  validates :name, :section1, presence: true
  validates :name, length: {in: 4..32}
  validates :section1, :section2, :section3, :section4, :section5, length: {in: 2..32}
end
