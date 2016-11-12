class AddApprovedToHelpPages < ActiveRecord::Migration
  def change
    add_column :help_pages, :approved, :boolean, default: false, null: false, after: :comments_count
  end
end
