class RenameIncorrectNoteColumns < ActiveRecord::Migration
  def change
    rename_column :compatibility_notes, :incorrect_notes_count, :corrections_count
    rename_column :install_order_notes, :incorrect_notes_count, :corrections_count
    add_column :load_order_notes, :corrections_count, :integer, default: 0
    rename_column :reviews, :incorrect_notes_count, :corrections_count
    rename_column :users, :incorrect_notes_count, :corrections_count
    rename_column :games, :incorrect_notes_count, :corrections_count

    # handle agreement marks reference
    remove_foreign_key :agreement_marks, :column => :incorrect_note_id
    rename_column :agreement_marks, :incorrect_note_id, :correction_id
    add_foreign_key :agreement_marks, :corrections
  end
end
