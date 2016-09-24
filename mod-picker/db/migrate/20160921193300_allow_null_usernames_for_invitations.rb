class AllowNullUsernamesForInvitations < ActiveRecord::Migration
  def change
    change_column :users, :username, :string, limit: 32, null: true
  end
end
