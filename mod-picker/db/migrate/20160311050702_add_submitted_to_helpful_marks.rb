class AddSubmittedToHelpfulMarks < ActiveRecord::Migration
  def change
    add_column :helpful_marks, :submitted, :timestamp
  end
end
