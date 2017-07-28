class AddPayments < ActiveRecord::Migration
  def change
    create_table "payments", force: :cascade do |t|
      t.integer "user_id", null: false
      t.integer "amount", default: 1
      t.string "token"
      t.string "identifier"
      t.string "payer_id"
      t.boolean "recurring", default: false
      t.boolean "digital", default: false
      t.boolean "popup", default: false
      t.boolean "completed", default: false
      t.boolean "canceled", default: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end

    add_foreign_key :payments, :users
  end
end
