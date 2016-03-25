class AddIncorrectNoteColumns < ActiveRecord::Migration
  def change
    rename_column :incorrect_notes, :reason, :text_body
    add_column :incorrect_notes, :created_at, :timestamp
    add_column :incorrect_notes, :updated_at, :timestamp
  end
end
