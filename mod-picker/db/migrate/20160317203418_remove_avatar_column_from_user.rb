class RemoveAvatarColumnFromUser < ActiveRecord::Migration
  def change
    remove_column :users, :avatar
  end
end
