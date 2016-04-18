class CreateArticles < ActiveRecord::Migration
  def change
    create_table :articles do |t|
      t.string :title, null: false
      t.integer :submitted_by, null: false
      t.text :text_body, null: false

      t.timestamps null: false
    end

    add_foreign_key :articles, :users, :column => :submitted_by
  end
end
