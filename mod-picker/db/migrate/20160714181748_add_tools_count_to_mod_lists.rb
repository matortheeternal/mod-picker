class AddToolsCountToModLists < ActiveRecord::Migration
  def change
    add_column :mod_lists, :tools_count, :integer, default: 0, null: false, after: :description
  end
end
