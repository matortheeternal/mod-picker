class FixNoteCounterCacheColumns < ActiveRecord::Migration
  def change
    rename_column :mod_lists, :installation_notes_count, :install_order_notes_count
    add_column :mod_lists, :load_order_notes_count, :integer
    rename_column :users, :installation_notes_count, :install_order_notes_count
    add_column :users, :load_order_notes_count, :integer
  end
end
