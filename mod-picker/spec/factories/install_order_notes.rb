  # create_table "install_order_notes", force: :cascade do |t|
  #   t.integer  "submitted_by",   limit: 4,     null: false
  #   t.integer  "install_first",  limit: 4,     null: false
  #   t.integer  "install_second", limit: 4,     null: false
  #   t.datetime "submitted"
  #   t.datetime "edited"
  #   t.text     "text_body",      limit: 65535
  # end

FactoryGirl.define do
  factory :install_order_note do
    association :submitted_by, factory: :user
    association :install_first, factory: :mod
    association :install_second, factory: :mod
    # submitted DateTime.now
    text_body { Faker::Lorem.sentence(30, false, 6) }
  end
end