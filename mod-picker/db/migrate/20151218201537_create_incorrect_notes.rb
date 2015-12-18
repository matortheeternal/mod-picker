class CreateIncorrectNotes < ActiveRecord::Migration
  def change
    create_table :incorrect_notes do |t|
      t.integer :inc_id
      t.integer :r_id
      t.integer :cn_id
      t.integer :in_id
      t.integer :submitted_by
      t.text :reason

      t.timestamps null: false
    end
  end
end
