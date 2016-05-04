class CorrectReviewSections < ActiveRecord::Migration
  def change
    rename_column :review_sections, :categories_id, :category_id
    add_foreign_key :review_sections, :categories
    add_column :review_sections, :default, :boolean, default: false
  end
end
