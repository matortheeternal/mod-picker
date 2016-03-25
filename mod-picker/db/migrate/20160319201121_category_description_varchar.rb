class CategoryDescriptionVarchar < ActiveRecord::Migration
  def change
    change_column :categories, :description, :string
  end
end
