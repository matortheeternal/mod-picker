# create_table "load_order_notes", force: :cascade do |t|
#     t.integer  "submitted_by", limit: 4,     null: false
#     t.integer  "load_first",   limit: 4,     null: false
#     t.integer  "load_second",  limit: 4,     null: false
#     t.datetime "submitted"
#     t.datetime "edited"
#     t.text     "text_body",    limit: 65535
#   end

#   add_index "load_order_notes", ["load_first"], name: "fk_rails_d6c931c1cc", using: :btree
#   add_index "load_order_notes", ["load_second"], name: "fk_rails_af9e3c9509", using: :btree
#   add_index "load_order_notes", ["submitted_by"], name: "fk_rails_9992d700a9", using: :btree

FactoryGirl.define do
  factory :load_order_note do
    # FIXME: I feel like there should be a better way to do this association in load_order_notes
    association :submitted_by, factory: :user
    load_first  { FactoryGirl.create(:plugin).id }
    load_second { FactoryGirl.create(:plugin).id }
    # submitted DateTime.now
    text_body { Faker::Lorem.sentence(30, false, 6) }

    # after(:build) do |load_order_note, evaluator|

    # end
  end
end