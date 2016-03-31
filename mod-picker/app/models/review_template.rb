class ReviewTemplate < ActiveRecord::Base
  belongs_to :user, :foreign_key => 'submitted_by', :inverse_of => 'reviews'
  has_many :reviews, :inverse_of => 'review_template'
end
