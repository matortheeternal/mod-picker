class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.integer :c_id
      t.integer :parent_comment
      t.integer :submitted_by
      t.boolean :hidden
      t.datetime :submitted
      t.datetime :edited

      t.timestamps null: false
    end
  end
end
