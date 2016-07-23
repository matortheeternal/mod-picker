class AddIndexToModListGroups < ActiveRecord::Migration
  def change
    add_column :mod_list_groups, :index, :integer, limit: 2, null: false, after: :mod_list_id
  end
end
