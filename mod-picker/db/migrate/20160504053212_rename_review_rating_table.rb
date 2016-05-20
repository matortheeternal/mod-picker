class RenameReviewRatingTable < ActiveRecord::Migration
  def change
    rename_table :review_rating, :review_ratings
  end
end
