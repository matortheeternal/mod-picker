class AddSubmittedByToMods < ActiveRecord::Migration
  def change
    add_column :mods, :submitted_by, :integer, null: false
    add_foreign_key :mods, :users, :column => 'submitted_by'
  end
end
