class CreateModListCompatibilityNotes < ActiveRecord::Migration
  def change
    create_table :mod_list_compatibility_notes do |t|
      t.integer :ml_id
      t.integer :cn_id
      t.integer :status

      t.timestamps null: false
    end
  end
end
