class AddNoteCounterCacheColumnsToMods < ActiveRecord::Migration
  def change
    add_column :mods, :compatibility_notes_count, :integer
    add_column :mods, :install_order_notes_count, :integer
    add_column :mods, :load_order_notes_count, :integer
  end
end
