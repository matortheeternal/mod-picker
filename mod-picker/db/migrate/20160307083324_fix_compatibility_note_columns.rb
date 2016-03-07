class FixCompatibilityNoteColumns < ActiveRecord::Migration
  def change
    remove_foreign_key :compatibility_notes, column: :installation_note_id
    remove_column :compatibility_notes, :installation_note_id
    add_column :compatibility_notes, :compatibility_mod_id, :integer

    execute("ALTER TABLE compatibility_notes CHANGE compatibility_status compatibility_type ENUM('Incompatible', 'Partially Incompatible', 'Compatibility Mod', 'Compatibility Plugin', 'Make Custom Patch');")
    execute("ALTER TABLE compatibility_notes MODIFY compatibility_mod_id INT UNSIGNED;")
  end
end
