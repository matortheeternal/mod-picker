class IncorrectNotePolymorphism < ActiveRecord::Migration
  def change
    remove_foreign_key :incorrect_notes, column: :review_id
    remove_foreign_key :incorrect_notes, column: :compatibility_note_id
    remove_foreign_key :incorrect_notes, column: :installation_note_id

    remove_columns :incorrect_notes, :review_id, :compatibility_note_id, :installation_note_id

    change_table :incorrect_notes do |t|
      t.references :correctable, polymorphic: true, index: true
    end

    reversible do |dir|
      dir.up do
        execute("ALTER TABLE incorrect_notes MODIFY correctable_id INT UNSIGNED")
      end
    end
  end
end
