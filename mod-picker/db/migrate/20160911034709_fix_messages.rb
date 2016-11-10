class FixMessages < ActiveRecord::Migration
  def change
    rename_column :messages, :created, :submitted
    rename_column :messages, :updated, :edited
    add_column :messages, :sent_to, :integer, after: :submitted_by
    add_foreign_key :messages, :users, column: :sent_to
  end
end
