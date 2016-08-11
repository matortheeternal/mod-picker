class RemoveUnusedModListNoteTables < ActiveRecord::Migration
  def change
    drop_table :mod_list_compatibility_notes
    drop_table :mod_list_install_order_notes
    drop_table :mod_list_load_order_notes
  end
end
