# create_table "compatibility_note_history_entries", force: :cascade do |t|
#     t.integer  "compatibility_note_id",   limit: 4,                 null: false
#     t.string   "edit_summary",            limit: 255,               null: false
#     t.integer  "submitted_by",            limit: 4,                 null: false
#     t.integer  "compatibility_mod_id",    limit: 4
#     t.integer  "compatibility_plugin_id", limit: 4
#     t.integer  "compatibility_type",      limit: 1,     default: 0, null: false
#     t.datetime "submitted"
#     t.datetime "edited"
#     t.text     "text_body",               limit: 65535
#   end

#   add_index "compatibility_note_history_entries", ["compatibility_mod_id"], name: "fk_rails_e1c933535e", using: :btree
#   add_index "compatibility_note_history_entries", ["compatibility_note_id"], name: "fk_rails_4970df5c77", using: :btree
#   add_index "compatibility_note_history_entries", ["compatibility_plugin_id"], name: "fk_rails_6466cbf704", using: :btree
#   add_index "compatibility_note_history_entries", ["submitted_by"], name: "fk_rails_7e4343a2d1", using: :btree

FactoryGirl.define do
  factory :compatibility_note_history_entry do
    association :compatibility_note, factory: :compatibility_note
    edit_summary { Faker::Lorem.sentence(3)}
    association :user, factory: :user
    association :compatibility_mod_id, factory: :mod
    association :compatibility_plugin_id, factory: :plugin
    compatibility_type "incompatible"
    text_body { Faker::Lorem.sentence(20) }
  end
end
