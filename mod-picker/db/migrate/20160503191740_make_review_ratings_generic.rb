class MakeReviewRatingsGeneric < ActiveRecord::Migration
  def change
    remove_column :reviews, :rating1
    remove_column :reviews, :rating2
    remove_column :reviews, :rating3
    remove_column :reviews, :rating4
    remove_column :reviews, :rating5

    remove_column :reviews, :review_section1_id
    remove_column :reviews, :review_section2_id
    remove_column :reviews, :review_section3_id
    remove_column :reviews, :review_section4_id
    remove_column :reviews, :review_section5_id

    create_table "review_rating", id: false do |t|
      t.references :review
      t.references :review_section
      t.integer    :rating, limit: 1
    end
  end
end
