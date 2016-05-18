class AddModCounters < ActiveRecord::Migration
  def change
    add_column :mods, :plugins_count, :integer, default: 0
    add_column :mods, :requirements_count, :integer, default: 0
    add_column :mods, :mod_lists_count, :integer, default: 0
    add_column :mods, :asset_files_count, :integer, default: 0
  end
end
