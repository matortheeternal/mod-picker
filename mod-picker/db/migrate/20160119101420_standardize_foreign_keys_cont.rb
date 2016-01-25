class StandardizeForeignKeysCont < ActiveRecord::Migration
  def change
    rename_column :compatibility_notes, :in_id, :installation_note_id
    rename_column :plugins, :mv_id, :mod_version_id
  end
end
