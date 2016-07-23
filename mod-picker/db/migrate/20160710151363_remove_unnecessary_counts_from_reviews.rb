class RemoveUnnecessaryCountsFromReviews < ActiveRecord::Migration
  def change
    remove_column :reviews, :history_entries_count
    remove_column :reviews, :corrections_count
  end
end
