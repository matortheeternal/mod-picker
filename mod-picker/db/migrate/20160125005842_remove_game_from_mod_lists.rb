class RemoveGameFromModLists < ActiveRecord::Migration
  def change
    remove_column :mod_lists, :game
  end
end
