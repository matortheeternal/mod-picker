class AddEditedByToModsAndModLists < ActiveRecord::Migration
  def change
    add_column :mods, :edited_by, :integer, after: :submitted_by
    add_foreign_key :mods, :users, column: :edited_by
    add_column :mod_lists, :edited_by, :integer, after: :submitted_by
    add_foreign_key :mod_lists, :users, column: :edited_by
  end
end
