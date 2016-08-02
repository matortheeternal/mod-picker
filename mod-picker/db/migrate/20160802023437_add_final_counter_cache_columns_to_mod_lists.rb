class AddFinalCounterCacheColumnsToModLists < ActiveRecord::Migration
  def change
    change_column :mod_lists, :custom_mods_count, :integer, default: 0, null: false, after: :mods_count

    add_column :mod_lists, :master_plugins_count, :integer, default: 0, null: false, after: :plugins_count
    add_column :mod_lists, :compatibility_notes_count, :integer, default: 0, null: false, after: :custom_config_files_count
    add_column :mod_lists, :install_order_notes_count, :integer, default: 0, null: false, after: :compatibility_notes_count
    add_column :mod_lists, :load_order_notes_count, :integer, default: 0, null: false, after: :install_order_notes_count
    add_column :mod_lists, :bsa_files_count, :integer, default: 0, null: false, after: :ignored_notes_count
    add_column :mod_lists, :asset_files_count, :integer, default: 0, null: false, after: :bsa_files_count
    add_column :mod_lists, :records_count, :integer, default: 0, null: false, after: :asset_files_count
    add_column :mod_lists, :override_records_count, :integer, default: 0, null: false, after: :records_count
    add_column :mod_lists, :plugin_errors_count, :integer, default: 0, null: false, after: :override_records_count
  end
end
