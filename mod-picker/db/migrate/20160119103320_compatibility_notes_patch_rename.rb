class CompatibilityNotesPatchRename < ActiveRecord::Migration
  def change
    rename_column :compatibility_notes, :compatibility_patch, :compatibility_plugin_id
  end
end
