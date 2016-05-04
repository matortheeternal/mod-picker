class AddReviewRatingIndexes < ActiveRecord::Migration
  def change
    add_foreign_key :review_rating, :reviews
    add_foreign_key :review_rating, :review_sections
  end
end
