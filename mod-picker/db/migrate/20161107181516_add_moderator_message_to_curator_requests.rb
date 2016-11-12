class AddModeratorMessageToCuratorRequests < ActiveRecord::Migration
  def change
    add_column :curator_requests, :moderator_message, :string, after: :state
  end
end
