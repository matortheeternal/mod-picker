class AddLoadOrderNoteHistoryEntriesTable < ActiveRecord::Migration
  def change
    create_table :load_order_note_history_entries do |t|
      t.integer   :load_order_note_id, null: false
      t.string    :edit_summary, null: false, limit: 255
      t.integer   :submitted_by, null: false
      t.integer   :load_first
      t.integer   :load_second
      t.datetime  :submitted
      t.datetime  :edited
      t.text      :text_body
    end

    # add foreign keys
    add_foreign_key :load_order_note_history_entries, :load_order_notes
    add_foreign_key :load_order_note_history_entries, :users, column: :submitted_by
    add_foreign_key :load_order_note_history_entries, :plugins, column: :load_first
    add_foreign_key :load_order_note_history_entries, :plugins, column: :load_second
  end
end
