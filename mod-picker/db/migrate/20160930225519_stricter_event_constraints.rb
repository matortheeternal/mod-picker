class StricterEventConstraints < ActiveRecord::Migration
  def change
    Event.where(content_id: nil).destroy_all
    Event.where(content_type: nil).destroy_all

    change_column :events, :content_id, :integer, null: false
    change_column :events, :content_type, :string, limit: 32, null: false
  end
end
