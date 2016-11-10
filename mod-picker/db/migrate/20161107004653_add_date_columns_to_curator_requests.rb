class AddDateColumnsToCuratorRequests < ActiveRecord::Migration
  def change
    add_column :curator_requests, :submitted, :datetime, null: false
    add_column :curator_requests, :updated, :datetime
  end
end
