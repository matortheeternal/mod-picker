class AddAuthorsColumnToMods < ActiveRecord::Migration
  def change
    add_column :mods, :authors, :string, limit: 128, null: false
  end
end
