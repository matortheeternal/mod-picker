# create_table "mod_version_compatibility_notes", id: false, force: :cascade do |t|
#     t.integer "mod_version_id",        limit: 4
#     t.integer "compatibility_note_id", limit: 4
#   end

#   add_index "mod_version_compatibility_notes", ["compatibility_note_id"], name: "fk_rails_29b33b572e", using: :btree
#   add_index "mod_version_compatibility_notes", ["mod_version_id"], name: "fk_rails_f7085a6344", using: :btree

FactoryGirl.define do
  factory :mod_version_compatibility_note do
    association :mod_version_id, factory: :mod_version_id
    association :compatibility_note_id, factory: :compatibility_note
  end

end
