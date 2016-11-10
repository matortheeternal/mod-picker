# create_table "mod_lists", force: :cascade do |t|
#     t.integer  "created_by",                limit: 4
#     t.boolean  "is_collection"
#     t.boolean  "is_public"
#     t.boolean  "has_adult_content"
#     t.integer  "status",                    limit: 1,     default: 0, null: false
#     t.datetime "created"
#     t.datetime "completed"
#     t.text     "description",               limit: 65535
#     t.integer  "game_id",                   limit: 4
#     t.integer  "comments_count",            limit: 4,     default: 0
#     t.integer  "mods_count",                limit: 4,     default: 0
#     t.integer  "plugins_count",             limit: 4,     default: 0
#     t.integer  "custom_plugins_count",      limit: 4,     default: 0
#     t.integer  "compatibility_notes_count", limit: 4,     default: 0
#     t.integer  "install_order_notes_count", limit: 4,     default: 0
#     t.integer  "user_stars_count",          limit: 4,     default: 0
#     t.integer  "load_order_notes_count",    limit: 4,     default: 0
#     t.string   "name",                      limit: 255
#   end

#   add_index "mod_lists", ["created_by"], name: "created_by", using: :btree
#   add_index "mod_lists", ["game_id"], name: "fk_rails_f25cbc0432", using: :btree

FactoryGirl.define do
  factory :mod_list do
    name { Faker::Name.name }
    association :user, factory: :user
    has_adult_content false
    status "under construction"
    description { Faker::Lorem.sentence(4, false, 6) }
    association :game, factory: :game
    is_collection false
  end
end
