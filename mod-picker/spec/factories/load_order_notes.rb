 # create_table "load_order_notes", force: :cascade do |t|
#     t.integer  "game_id",               limit: 4,                     null: false
#     t.integer  "submitted_by",          limit: 4,                     null: false
#     t.integer  "first_plugin_id",       limit: 4,                     null: false
#     t.integer  "second_plugin_id",      limit: 4,                     null: false
#     t.text     "text_body",             limit: 65535,                 null: false
#     t.string   "edit_summary",          limit: 255
#     t.string   "moderator_message",     limit: 255
#     t.integer  "helpful_count",         limit: 4,     default: 0,     null: false
#     t.integer  "not_helpful_count",     limit: 4,     default: 0,     null: false
#     t.integer  "corrections_count",     limit: 4,     default: 0,     null: false
#     t.integer  "history_entries_count", limit: 4,     default: 0,     null: false
#     t.boolean  "approved",                            default: false, null: false
#     t.boolean  "hidden",                              default: false, null: false
#     t.datetime "submitted",                                           null: false
#     t.datetime "edited"
#   end

FactoryGirl.define do
  factory :load_order_note do
    # FIXME: I feel like there should be a better way to do this association in load_order_notes
    association :user, factory: :user
    first_plugin_id  { FactoryGirl.create(:plugin).id }
    second_plugin_id { FactoryGirl.create(:plugin).id }
    # submitted DateTime.now
    text_body { Faker::Lorem.sentence(60, false, 6) }
    game_id { FactoryGirl.create(:game).id }

    # after(:build) do |load_order_note, evaluator|

    # end
  end
end