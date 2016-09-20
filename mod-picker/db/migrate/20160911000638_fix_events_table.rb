class FixEventsTable < ActiveRecord::Migration
  def change
    change_column :events, :content_type, :string, limit: 32
    change_column :events, :event_type, :integer, limit: 1, null: false
  end
end
