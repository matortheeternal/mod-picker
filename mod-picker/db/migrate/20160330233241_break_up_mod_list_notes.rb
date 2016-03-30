class BreakUpModListNotes < ActiveRecord::Migration
  def change
    # change mod_list_notes back to mod_list_compatibility_notes
    rename_table :mod_list_notes, :mod_list_compatibility_notes
    remove_column :mod_list_compatibility_notes, :note_type
    rename_column :mod_list_compatibility_notes, :note_id, :compatibility_note_id
    add_foreign_key :mod_list_compatibility_notes, :compatibility_notes

    # update mod_list_installation_notes
    rename_table :mod_list_installation_notes, :mod_list_install_order_notes
    rename_column :mod_list_install_order_notes, :installation_note_id, :install_order_note_id
    change_column :mod_list_install_order_notes, :status, :enum, :limit => ["Unresolved", "Resolved", "Ignored"]

    # create mod_list_load_order_notes table
    create_table :mod_list_load_order_notes, id: false do |t|
      t.integer   :mod_list_id, null: false
      t.integer   :load_order_note_id, null: false
      t.enum      :status, limit: ["Unresolved", "Resolved", "Ignored"]
    end

    add_foreign_key :mod_list_load_order_notes, :mod_lists
    add_foreign_key :mod_list_load_order_notes, :load_order_notes
    add_index :mod_list_load_order_notes, :mod_list_id
    add_index :mod_list_load_order_notes, :load_order_note_id
  end
end
