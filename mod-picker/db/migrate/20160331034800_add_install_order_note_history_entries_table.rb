class AddInstallOrderNoteHistoryEntriesTable < ActiveRecord::Migration
  def change
    create_table :install_order_note_history_entries do |t|
      t.integer   :install_order_note_id, null: false
      t.string    :edit_summary, null: false, limit: 255
      t.integer   :submitted_by, null: false
      t.integer   :install_first
      t.integer   :install_second
      t.datetime  :submitted
      t.datetime  :edited
      t.text      :text_body
    end

    # add foreign keys
    add_foreign_key :install_order_note_history_entries, :install_order_notes
    add_foreign_key :install_order_note_history_entries, :users, column: :submitted_by
    add_foreign_key :install_order_note_history_entries, :mods, column: :install_first
    add_foreign_key :install_order_note_history_entries, :mods, column: :install_second
  end
end
