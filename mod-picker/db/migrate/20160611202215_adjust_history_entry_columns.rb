class AdjustHistoryEntryColumns < ActiveRecord::Migration
  def change
    remove_foreign_key :compatibility_note_history_entries, column: :submitted_by
    remove_foreign_key :install_order_note_history_entries, column: :submitted_by
    remove_foreign_key :load_order_note_history_entries, column: :submitted_by

    rename_column :compatibility_note_history_entries, :submitted_by, :edited_by
    rename_column :install_order_note_history_entries, :submitted_by, :edited_by
    rename_column :load_order_note_history_entries, :submitted_by, :edited_by

    add_foreign_key :compatibility_note_history_entries, :users, column: :edited_by
    add_foreign_key :install_order_note_history_entries, :users, column: :edited_by
    add_foreign_key :load_order_note_history_entries, :users, column: :edited_by

    remove_column :compatibility_note_history_entries, :submitted
    remove_column :install_order_note_history_entries, :submitted
    remove_column :load_order_note_history_entries, :submitted
  end
end
