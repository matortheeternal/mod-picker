class AddModVersionLoadOrderNotesTable < ActiveRecord::Migration
  def change
    create_table :mod_version_load_order_notes do |t|
      t.integer   :mod_version_id, null: false
      t.integer   :load_order_note_id, null: false
    end

    add_foreign_key :mod_version_load_order_notes, :mod_versions
    add_foreign_key :mod_version_load_order_notes, :load_order_notes
  end
end
