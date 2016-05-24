class AddIncorrectNoteCounterCacheColumns < ActiveRecord::Migration
  def change
    add_column :incorrect_notes, :comments_count, :integer, default: 0
    add_column :incorrect_notes, :agree_count, :integer, default: 0
    add_column :incorrect_notes, :disagree_count, :integer, default: 0
  end
end
