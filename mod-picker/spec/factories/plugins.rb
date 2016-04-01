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
    id 1
mod_version_id 1
filename "MyText"
author "MyText"
description "MyText"
hash "MyString"
  end

end
