# create_table "compatibility_notes", force: :cascade do |t|
#     t.integer  "submitted_by",            limit: 4
#     t.integer  "compatibility_plugin_id", limit: 4
#     t.integer  "compatibility_type",      limit: 1,     default: 0,     null: false
#     t.datetime "submitted"
#     t.datetime "edited"
#     t.text     "text_body",               limit: 65535
#     t.integer  "incorrect_notes_count",   limit: 4,     default: 0
#     t.integer  "compatibility_mod_id",    limit: 4
#     t.boolean  "hidden",                                default: false, null: false
#   end

FactoryGirl.define do
  factory :compatibility_note do
    association :user, factory: :user
    compatibility_type "incompatible"
    text_body { Faker::Lorem.sentence(20, false, 6) }
  end
end
