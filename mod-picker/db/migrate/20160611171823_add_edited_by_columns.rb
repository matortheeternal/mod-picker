class AddEditedByColumns < ActiveRecord::Migration
  def change
    add_column :compatibility_notes, :edited_by, :integer, after: :submitted_by
    add_foreign_key :compatibility_notes, :users, column: :edited_by

    add_column :corrections, :edited_by, :integer, after: :submitted_by
    add_foreign_key :corrections, :users, column: :edited_by

    add_column :install_order_notes, :edited_by, :integer, after: :submitted_by
    add_foreign_key :install_order_notes, :users, column: :edited_by

    add_column :load_order_notes, :edited_by, :integer, after: :submitted_by
    add_foreign_key :load_order_notes, :users, column: :edited_by

    add_column :reviews, :edited_by, :integer, after: :submitted_by
    add_foreign_key :reviews, :users, column: :edited_by
  end
end
