class CombineCategoryPriorityColumns < ActiveRecord::Migration
  def change
    remove_column :categories, :load_order_priority
    rename_column :categories, :install_order_priority, :priority
  end
end
