# create_table "compatibility_notes", force: :cascade do |t|
#     t.integer  "submitted_by",            limit: 4
#     t.integer  "compatibility_plugin_id", limit: 4
#     t.integer  "compatibility_type",      limit: 1,     default: 0,     null: false
#     t.datetime "submitted"
#     t.datetime "edited"
#     t.text     "text_body",               limit: 65535
#     t.integer  "corrections_count",       limit: 4,     default: 0
#     t.integer  "compatibility_mod_id",    limit: 4
#     t.boolean  "hidden",                                default: false, null: false
#     t.integer  "first_mod_id",            limit: 4
#     t.integer  "second_mod_id",           limit: 4
#     t.integer  "game_id",                 limit: 4,                     null: false
#     t.boolean  "approved",                              default: false
#     t.string   "moderator_message",       limit: 255
#     t.integer  "helpful_count",           limit: 4,     default: 0
#     t.integer  "not_helpful_count",       limit: 4,     default: 0
#     t.integer  "history_entries_count",   limit: 4,     default: 0
#   end

FactoryGirl.define do
  factory :compatibility_note do
    association :user, factory: :user
    compatibility_mod_id { FactoryGirl.create(:mod).id }
    first_mod_id { FactoryGirl.create(:mod).id }
    second_mod_id { FactoryGirl.create(:mod).id }
    game_id       { FactoryGirl.create(:game).id }
    text_body { Faker::Lorem.sentence(60, false, 0) }
  end
end
