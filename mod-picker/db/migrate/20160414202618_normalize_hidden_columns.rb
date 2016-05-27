class NormalizeHiddenColumns < ActiveRecord::Migration
  def change
    rename_column :mod_lists, :is_public, :hidden
    rename_column :tags, :disabled, :hidden
    change_column :mod_lists, :hidden, :boolean, :null => false, :default => true
    change_column :tags, :hidden, :boolean, :null => false, :default => false
    add_column :corrections, :hidden, :boolean, :null => false, :default => false
    add_column :compatibility_notes, :hidden, :boolean, :null => false, :default => false
    add_column :install_order_notes, :hidden, :boolean, :null => false, :default => false
    add_column :load_order_notes, :hidden, :boolean, :null => false, :default => false
    add_column :mods, :hidden, :boolean, :null => false, :default => false
  end
end
