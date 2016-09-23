class AdultContentPropagation < ActiveRecord::Migration
  def change
    add_column :reviews, :has_adult_content, :boolean, default: false, null: false, after: :hidden
    add_column :comments, :has_adult_content, :boolean, default: false, null: false, after: :hidden
    add_column :compatibility_notes, :has_adult_content, :boolean, default: false, null: false, after: :hidden
    add_column :install_order_notes, :has_adult_content, :boolean, default: false, null: false, after: :hidden
    add_column :load_order_notes, :has_adult_content, :boolean, default: false, null: false, after: :hidden
    add_column :corrections, :has_adult_content, :boolean, default: false, null: false, after: :hidden
  end
end
