class CreateCompatibilityNotes < ActiveRecord::Migration
  def change
    create_table :compatibility_notes do |t|
      t.integer :cn_id
      t.integer :submitted_by
      t.integer :mod_mode
      t.integer :compatibility_patch
      t.integer :compatibility_status

      t.timestamps null: false
    end
  end
end
