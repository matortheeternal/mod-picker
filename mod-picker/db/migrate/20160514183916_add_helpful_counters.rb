class AddHelpfulCounters < ActiveRecord::Migration
  def change
    add_column :reviews, :helpful_count, :integer, default: 0
    add_column :reviews, :not_helpful_count, :integer, default: 0
    add_column :compatibility_notes, :helpful_count, :integer, default: 0
    add_column :compatibility_notes, :not_helpful_count, :integer, default: 0
    add_column :install_order_notes, :helpful_count, :integer, default: 0
    add_column :install_order_notes, :not_helpful_count, :integer, default: 0
    add_column :load_order_notes, :helpful_count, :integer, default: 0
    add_column :load_order_notes, :not_helpful_count, :integer, default: 0
  end
end
