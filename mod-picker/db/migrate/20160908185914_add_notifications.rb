class AddNotifications < ActiveRecord::Migration
  def change
    create_table "events" do |t|
      t.integer :content_id, null: false
      t.string :content_type, limit: 32, null: false
      t.integer :event_type, limit: 1, null: false
      t.datetime :created, null: false
      t.references :content, :polymorphic => true
    end

    create_table "messages" do |t|
      t.integer :submitted_by, null: false
      t.text :text, null: false
      t.datetime :created, null: false
      t.datetime :updated
      t.foreign_key :users, column: :submitted_by
    end

    create_table "read_notifications", id: false do |t|
      t.integer :event_id, null: false
      t.integer :user_id, null: false
      t.foreign_key :events
      t.foreign_key :users
    end
  end
end
