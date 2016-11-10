class AddIdToModAuthors < ActiveRecord::Migration
  def change
    add_column :mod_authors, :id, :primary_key
  end
end
