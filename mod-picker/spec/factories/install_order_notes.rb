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
    # submitted TimeDate.current; should be done in the model
    association :submitted_by, factory: :user
    install_first 1
    install_second 2
    # submitted DateTime.now
    text_body { Faker::Lorem.sentence(30, false, 6) }
  end
end