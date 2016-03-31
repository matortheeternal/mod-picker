class RemoveInstallationNotesTable < ActiveRecord::Migration
  def change
    remove_foreign_key :mod_list_install_order_notes, :install_order_notes
    add_foreign_key :mod_list_install_order_notes, :install_order_notes

    drop_table :installation_notes
  end
end
