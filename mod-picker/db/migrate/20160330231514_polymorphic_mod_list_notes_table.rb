class PolymorphicModListNotesTable < ActiveRecord::Migration
  def change
    rename_table :mod_list_compatibility_notes, :mod_list_notes
    remove_foreign_key :mod_list_notes, column: :compatibility_note_id
    rename_column :mod_list_notes, :compatibility_note_id, :note_id
    add_column :mod_list_notes, :note_type, :string
    change_column :mod_list_notes, :status, :enum, :limit => ['Unresolved', 'Resolved', 'Ignored'], default: 'Unresolved'
  end
end
