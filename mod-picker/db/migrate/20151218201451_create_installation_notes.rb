class CreateInstallationNotes < ActiveRecord::Migration
  def change
    create_table :installation_notes do |t|
      t.integer :in_id
      t.integer :submitted_by
      t.integer :mv_id
      t.boolean :always
      t.integer :note_type
      t.datetime :submitted
      t.datetime :edited

      t.timestamps null: false
    end
  end
end
