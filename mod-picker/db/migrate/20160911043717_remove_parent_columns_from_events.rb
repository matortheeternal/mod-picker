class RemoveParentColumnsFromEvents < ActiveRecord::Migration
  def change
    remove_column :events, :parent_id
    remove_column :events, :parent_type
  end
end
