class CreateArticles < ActiveRecord::Migration
  def change
    create_table :articles, id: false do |t|
      t.string :title, :primary_key
      t.integer :submitted_by
      t.text :text_body

      t.timestamps null: false
    end

    add_foreign_key :articles, :users, :column => :submitted_by
  end
end
