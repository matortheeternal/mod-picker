class ModCategoryIds < ActiveRecord::Migration
  def change
    rename_column :mods, :primary_category, :primary_category_id
    rename_column :mods, :secondary_category, :secondary_category_id
  end
end
