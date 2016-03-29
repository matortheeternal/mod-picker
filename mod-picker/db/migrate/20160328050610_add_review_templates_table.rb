class AddReviewTemplatesTable < ActiveRecord::Migration
  def change
    create_table :review_templates do |t|
      t.string    :name, null: false
      t.integer   :submitted_by, null: false
      t.datetime  :submitted, :edited
      t.string    :section1, null: false, limit: 32
      t.string    :section2, :section3, :section4, :section5, limit: 32
    end

    # add foreign key
    add_foreign_key :review_templates, :users, column: :submitted_by

    # modify reviews
    add_column :reviews, :review_template_id, :integer
    add_foreign_key :reviews, :review_templates, column: :review_template_id
  end
end
