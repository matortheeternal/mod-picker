class AddUserToHelpPage < ActiveRecord::Migration
  def change
    add_column :help_pages, :submitted_by, :integer, limit: 4, null: false, index: true
    add_foreign_key :help_pages, :users, column: :submitted_by
  end
end
