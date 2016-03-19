class AddDescriptionToCategoryPriorities < ActiveRecord::Migration
  def change
    add_column :category_priorities, :description, :string
  end
end
