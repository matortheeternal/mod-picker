class FixEditSummaryColumnType < ActiveRecord::Migration
  def change
    change_column :compatibility_note_history_entries, :edit_summary, :string, null: false
  end
end
