# create_table "games", force: :cascade do |t|
#   t.string "display_name",  limit: 32
#   t.string "long_name",     limit: 128
#   t.string "abbr_name",     limit: 32
#   t.string "exe_name",      limit: 32
#   t.string "steam_app_ids", limit: 64
#   t.string "nexus_name",    limit: 16
# end

FactoryGirl.define do
  factory :game do
    display_name { Faker::Internet.user_name[1..32] }
    long_name { Faker::Name.name }
    abbr_name { Faker::Name.suffix }
    exe_name "#{ Faker::Name.suffix }" + ".exe"
    nexus_name { Faker::Name.name[1..16] }
    steam_app_ids { Faker::Number.number(5) }
  end
end