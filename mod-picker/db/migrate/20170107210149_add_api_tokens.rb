class AddApiTokens < ActiveRecord::Migration
  def change
    create_table "api_tokens" do |t|
      t.integer :user_id, null: false
      t.string :name, limit: 64, null: false
      t.string :api_key, limit: 24, null: false
      t.integer :requests_count, limit: 8, default: 0, null: false
      t.boolean :expired, default: false, null: false
      t.datetime :created, null: false
      t.datetime :date_expired
    end

    add_foreign_key :api_tokens, :users
  end
end
