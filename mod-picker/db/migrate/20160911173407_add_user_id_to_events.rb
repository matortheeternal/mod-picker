class AddUserIdToEvents < ActiveRecord::Migration
  def change
    add_column :events, :user_id, :integer, after: :id
    add_foreign_key :events, :users
  end
end
