class AddPremiumAccounts < ActiveRecord::Migration
  def change
    create_table :premium_subscriptions do |t|
      t.integer :user_id
      t.integer :subscription_type, limit: 1, null: false
      t.datetime :purchased, null: false
      t.datetime :start, null: false
      t.datetime :end, null: false
    end

    add_foreign_key :premium_subscriptions, :users
  end
end
