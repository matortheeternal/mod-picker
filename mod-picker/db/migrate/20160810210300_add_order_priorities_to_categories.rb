class AddOrderPrioritiesToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :install_order_priority, :integer, default: 0, null: false
    add_column :categories, :load_order_priority, :integer, default: 0, null: false
  end
end
