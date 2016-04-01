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
    id 1
    mod_id 1
    nxm_file_id 1
    released "2016-01-19 01:11:38"
    obsolete false
    dangerous false
  end
end
