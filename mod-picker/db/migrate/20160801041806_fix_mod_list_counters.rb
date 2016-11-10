class FixModListCounters < ActiveRecord::Migration
  def change
    remove_column :mod_lists, :compatibility_notes_count
    remove_column :mod_lists, :install_order_notes_count
    remove_column :mod_lists, :load_order_notes_count
    add_column :mod_lists, :ignored_notes_count, :integer, default: 0, null: false, after: :custom_config_files_count
  end
end
