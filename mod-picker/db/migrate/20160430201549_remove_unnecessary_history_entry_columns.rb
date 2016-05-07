class RemoveUnnecessaryHistoryEntryColumns < ActiveRecord::Migration
  def change
    ### load_order_note_history_entries ###
    remove_foreign_key :load_order_note_history_entries, column: :load_first
    remove_foreign_key :load_order_note_history_entries, column: :load_second
    remove_column :load_order_note_history_entries, :load_first
    remove_column :load_order_note_history_entries, :load_second

    ### install_order_note_history_entries ###
    remove_foreign_key :install_order_note_history_entries, column: :install_first
    remove_foreign_key :install_order_note_history_entries, column: :install_second
    remove_column :install_order_note_history_entries, :install_first
    remove_column :install_order_note_history_entries, :install_second
  end
end
