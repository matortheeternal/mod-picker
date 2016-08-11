class AddModAuthorRole < ActiveRecord::Migration
  def change
    add_column :mod_authors, :role, :integer, limit: 1, default: 0, null: false
  end
end
