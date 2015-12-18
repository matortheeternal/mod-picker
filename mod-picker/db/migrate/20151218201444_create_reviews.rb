class CreateReviews < ActiveRecord::Migration
  def change
    create_table :reviews do |t|
      t.integer :r_id
      t.integer :submitted_by
      t.integer :mod_id
      t.boolean :hidden
      t.string :rating1
      t.string :TINYINT
      t.string :rating2
      t.string :TINYINT
      t.string :rating3
      t.string :TINYINT
      t.string :rating4
      t.string :TINYINT
      t.string :rating5
      t.string :TINYINT
      t.datetime :submitted
      t.datetime :edited

      t.timestamps null: false
    end
  end
end
