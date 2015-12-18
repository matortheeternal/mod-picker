class CreateModLists < ActiveRecord::Migration
  def change
    create_table :mod_lists do |t|
      t.integer :ml_id
      t.text :game
      t.integer :created_by
      t.boolean :is_collection
      t.boolean :is_public
      t.boolean :has_adult_content
      t.integer :status
      t.datetime :created
      t.datetime :completed
      t.text :description

      t.timestamps null: false
    end
  end
end
