# create_table "asset_files", force: :cascade do |t|
#   t.integer "game_id",               limit: 4,               null: false
#   t.string  "filepath",              limit: 255,             null: false
#   t.integer "mod_asset_files_count", limit: 4,   default: 0, null: false
# end
FactoryGirl.define do
  factory :asset_file do
    association :game, factory: :game
    filepath { Faker::Name.name }
  end

end