class AddKeepWhenSortingToModListGroups < ActiveRecord::Migration
  def change
    add_column :mod_list_groups, :keep_when_sorting, :boolean, default: false, null: false, after: :color
  end
end
