class AddMissingIndexes < ActiveRecord::Migration
  def change
    add_index :base_reports, [:reportable_id, :reportable_type]
    add_index :compatibility_notes, :compatibility_mod_id
    add_index :compatibility_notes, :compatibility_mod_option_id
    add_index :events, [:content_id, :content_type]
    add_index :mod_list_ignored_notes, [:note_id, :note_type]
    add_index :nexus_infos, :mod_id
    add_index :workshop_infos, :game_id
  end
end