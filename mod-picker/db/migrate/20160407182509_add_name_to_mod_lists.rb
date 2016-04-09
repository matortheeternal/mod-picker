class AddNameToModLists < ActiveRecord::Migration
  def change
    add_column :mod_lists, :name, :string
  end
end
