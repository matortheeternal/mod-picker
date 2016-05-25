class AddOverallRatingToReviews < ActiveRecord::Migration
  def change
    add_column :reviews, :overall_rating, :float, default: 0.0
  end
end
