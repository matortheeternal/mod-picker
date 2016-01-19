class TwoCategoriesForMods < ActiveRecord::Migration
  def change
    change_table :mods do |t|
      t.remove :category
      t.column :primary_category,   :integer
      t.column :secondary_category, :integer
    end

    reversible do |dir|
      dir.up do
        execute("ALTER TABLE mods MODIFY primary_category INT UNSIGNED")
        execute("ALTER TABLE mods MODIFY secondary_category INT UNSIGNED")
      end
    end

    add_foreign_key :mods, :categories, column: :primary_category
    add_foreign_key :mods, :categories, column: :secondary_category
  end
end
