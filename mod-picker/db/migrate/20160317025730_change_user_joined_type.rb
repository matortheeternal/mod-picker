class ChangeUserJoinedType < ActiveRecord::Migration
  def change
    change_column :users, :joined, :datetime
  end
end
