class FixEnumColumns < ActiveRecord::Migration
  def change
    change_column :compatibility_note_history_entries, :compatibility_type, :integer, :limit => 1, :null => false, :default => 0
    change_column :compatibility_notes, :compatibility_type, :integer, :limit => 1, :null => false, :default => 0
    change_column :mod_list_compatibility_notes, :status, :integer, :limit => 1, :null => false, :default => 0
    change_column :mod_list_install_order_notes, :status, :integer, :limit => 1, :null => false, :default => 0
    change_column :mod_list_load_order_notes, :status, :integer, :limit => 1, :null => false, :default => 0
    change_column :mod_lists, :status, :integer, :limit => 1, :null => false, :default => 0
    change_column :mods, :status, :integer, :limit => 1, :null => false, :default => 0
  end
end
