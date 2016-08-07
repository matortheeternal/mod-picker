class AddModListIgnoredNotes < ActiveRecord::Migration
  def change
    create_table "mod_list_ignored_notes" do |t|
      t.integer "mod_list_id", null: false
      t.integer "note_id", null: false
      t.string "note_type", null: false
    end

    add_foreign_key :mod_list_ignored_notes, :mod_lists
  end
end
