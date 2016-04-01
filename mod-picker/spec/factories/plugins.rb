# create_table "plugins", force: :cascade do |t|
#   t.integer "mod_version_id", limit: 4
#   t.string  "filename",       limit: 64
#   t.string  "author",         limit: 128
#   t.string  "description",    limit: 512
#   t.string  "crc_hash",       limit: 8
# end

# add_index "plugins", ["mod_version_id"], name: "mv_id", using: :btree

FactoryGirl.define do
  factory :plugin do
    mod_version_id 1
    filename "Skyrim.esm"
    author "Bethesda"
    description "The base Esm of skyrim"
    crc_hash "a461d80f"
  end

end
