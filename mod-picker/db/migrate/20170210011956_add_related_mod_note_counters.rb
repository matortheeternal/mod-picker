class AddRelatedModNoteCounters < ActiveRecord::Migration
  def change
    add_column :games, :related_mod_notes_count, :integer, default: 0, null: false, after: :load_order_notes_count
    add_column :mods, :related_mod_notes_count, :integer, default: 0, null: false, after: :load_order_notes_count
    add_column :users, :related_mod_notes_count, :integer, default: 0, null: false, after: :load_order_notes_count
  end
end
