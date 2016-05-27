# create_table "mod_list_compatibility_notes", id: false, force: :cascade do |t|
#     t.integer "mod_list_id",           limit: 4
#     t.integer "compatibility_note_id", limit: 4
#     t.integer "status",                limit: 1, default: 0, null: false
#   end

FactoryGirl.define do
  factory :mod_list_compatibility_note do
    association :mod_list, factory: :mod_list
    association :compatibility_note, factory: :compatibility_note
    # status "Resolved"
  end

end
