class CreateHelpfulMarks < ActiveRecord::Migration
  def change
    create_table :helpful_marks do |t|
      t.integer :r_id
      t.integer :cn_id
      t.integer :in_id
      t.integer :submitted_by
      t.boolean :helpful

      t.timestamps null: false
    end
  end
end
