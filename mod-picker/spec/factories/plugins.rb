# create_table "plugins", force: :cascade do |t|
#     t.integer "mod_id",                 limit: 4
#     t.string  "filename",               limit: 64
#     t.string  "author",                 limit: 128
#     t.string  "description",            limit: 512
#     t.string  "crc_hash",               limit: 8
#     t.integer "record_count",           limit: 4
#     t.integer "override_count",         limit: 4
#     t.integer "file_size",              limit: 4
#     t.integer "game_id",                limit: 4,               null: false
#     t.integer "errors_count",           limit: 4,   default: 0
#     t.integer "mod_lists_count",        limit: 4,   default: 0
#     t.integer "load_order_notes_count", limit: 4,   default: 0
#   end

FactoryGirl.define do
  factory :plugin do
    mod_id      { FactoryGirl.create(:mod).id }
    filename    { Faker::Internet.user_name[1..64] }
    author      { Faker::Internet.user_name[1..128] }
    description { Faker::Lorem.sentence(3, false, 4)[1..512] }
    crc_hash    { Faker::Lorem.sentence(2)[1..8] }
    game_id     { FactoryGirl.create(:game).id }
    file_size   { Faker::Number.number(2) }
  end
end
