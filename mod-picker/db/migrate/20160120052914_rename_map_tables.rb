class RenameMapTables < ActiveRecord::Migration
  def change
    rename_table :mod_version_compatibility_note_map, :mod_version_compatibility_notes
    rename_table :mod_version_file_map, :mod_version_files
    rename_table :plugin_override_map, :plugin_overrides
    rename_table :reputation_map, :reputation_links
    rename_table :user_mod_author_map, :mod_authors
    rename_table :user_mod_list_star_map, :mod_list_stars
    rename_table :user_mod_star_map, :mod_stars
  end
end
