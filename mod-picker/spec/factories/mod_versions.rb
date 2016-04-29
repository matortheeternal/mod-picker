# create_table "mod_versions", force: :cascade do |t|
#   t.integer  "mod_id",    limit: 4
#   t.datetime "released"
#   t.boolean  "obsolete"
#   t.boolean  "dangerous"
#   t.string   "version",   limit: 16
# end

# add_index "mod_versions", ["mod_id"], name: "mod_id", using: :btree


FactoryGirl.define do
  factory :mod_version do
    association :mod, factory: :mod
    released DateTime.now
    obsolete false
    dangerous false
    version { Faker::Number.decimal(1,1) }
  end
end
