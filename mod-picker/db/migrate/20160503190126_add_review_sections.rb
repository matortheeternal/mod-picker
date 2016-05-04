class AddReviewSections < ActiveRecord::Migration
  def change
    create_table "review_sections" do |t|
      t.references :categories
      t.string :name,         limit: 32, null: false
      t.string :prompt,       limit: 255, null: false
    end

    # remove review templates
    remove_foreign_key :reviews, :review_templates
    remove_column :reviews, :review_template_id
    drop_table :review_templates

    # add review sections to review
    add_column :reviews, :review_section1_id, :integer, null: false
    # use validations for second review section
    # this way we can have a single section review at some future date, if desired
    add_column :reviews, :review_section2_id, :integer
    add_column :reviews, :review_section3_id, :integer
    add_column :reviews, :review_section4_id, :integer
    add_column :reviews, :review_section5_id, :integer
  end
end
