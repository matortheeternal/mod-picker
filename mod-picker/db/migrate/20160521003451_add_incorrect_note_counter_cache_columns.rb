class AddCorrectionCounterCacheColumns < ActiveRecord::Migration
  def change
    add_column :corrections, :comments_count, :integer, default: 0
    add_column :corrections, :agree_count, :integer, default: 0
    add_column :corrections, :disagree_count, :integer, default: 0
  end
end
