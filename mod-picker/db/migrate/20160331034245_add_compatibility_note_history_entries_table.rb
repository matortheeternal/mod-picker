class AddCompatibilityNoteHistoryEntriesTable < ActiveRecord::Migration
  def change
    create_table :compatibility_note_history_entries do |t|
      t.integer   :compatibility_note_id, null: false
      t.string    :edit_summary, null: false, limit: 255
      t.integer   :submitted_by, null: false
      t.integer   :compatibility_mod_id
      t.integer   :compatibility_plugin_id
      t.enum      :compatibility_type, limit: ["Incompatible", "Partially Incompatible", "Compatibility Mod", "Compatibility Plugin", "Make Custom Patch"]
      t.datetime  :submitted
      t.datetime  :edited
      t.text      :text_body
    end

    # add foreign keys
    add_foreign_key :compatibility_note_history_entries, :compatibility_notes
    add_foreign_key :compatibility_note_history_entries, :users, column: :submitted_by
    add_foreign_key :compatibility_note_history_entries, :mods, column: :compatibility_mod_id
    add_foreign_key :compatibility_note_history_entries, :plugins, column: :compatibility_plugin_id
  end
end
