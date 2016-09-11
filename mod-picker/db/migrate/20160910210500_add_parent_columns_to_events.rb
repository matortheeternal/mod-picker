class AddParentColumnsToEvents < ActiveRecord::Migration
  def change
    add_column :events, :parent_id, :integer, after: :id
    add_column :events, :parent_type, :string, after: :parent_id

    change_column :events, :parent_type, :string, limit: 32
    change_column :events, :event_type, :string, limit: 32
  end
end
