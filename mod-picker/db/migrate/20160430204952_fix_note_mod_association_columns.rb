class FixNoteModAssociationColumns < ActiveRecord::Migration
  def change
    rename_column :compatibility_notes, :first_mod, :first_mod_id
    rename_column :compatibility_notes, :second_mod, :second_mod_id
    rename_column :install_order_notes, :install_first, :first_mod_id
    rename_column :install_order_notes, :install_second, :second_mod_id
    rename_column :load_order_notes, :load_first, :first_plugin_id
    rename_column :load_order_notes, :load_second, :second_plugin_id
  end
end
