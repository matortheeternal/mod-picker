class MakeModListCustomModGroupIdOptional < ActiveRecord::Migration
  def change
    change_column :mod_list_custom_mods, :group_id, :integer, null: true
  end
end
