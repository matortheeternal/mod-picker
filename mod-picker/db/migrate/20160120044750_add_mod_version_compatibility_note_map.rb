class AddModVersionCompatibilityNoteMap < ActiveRecord::Migration
  def change
    create_table "mod_version_compatibility_note_map", id: false do |t|
      t.integer "mod_version_id"
      t.integer "compatibility_note_id"
    end

    execute("ALTER TABLE mod_version_compatibility_note_map MODIFY mod_version_id INT UNSIGNED NOT NULL;")
    execute("ALTER TABLE mod_version_compatibility_note_map MODIFY compatibility_note_id INT UNSIGNED NOT NULL;")

    add_foreign_key :mod_version_compatibility_note_map, :mod_versions
    add_foreign_key :mod_version_compatibility_note_map, :compatibility_notes
  end
end
