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
    association :mod_version, factory: :mod_version
    filename { Faker::Internet.user_name[1..64] }
    author { Faker::Internet.user_name[1..128] }
    description { Faker::Lorem.sentence(3, false, 4)[1..512] }
    crc_hash { Faker::Lorem.sentence(2)[1..8] }
  end

end
