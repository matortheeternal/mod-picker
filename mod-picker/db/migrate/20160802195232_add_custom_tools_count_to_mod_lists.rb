class AddCustomToolsCountToModLists < ActiveRecord::Migration
  def change
    add_column :mod_lists, :custom_tools_count, :integer, default: 0, null: false, after: :mods_count
  end
end
