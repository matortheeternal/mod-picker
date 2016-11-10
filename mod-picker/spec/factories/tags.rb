# create_table "tags", force: :cascade do |t|
#   t.string  "text",            limit: 255,                 null: false
#   t.integer "game_id",         limit: 4,                   null: false
#   t.integer "submitted_by",    limit: 4,                   null: false
#   t.integer "mods_count",      limit: 4
#   t.integer "mod_lists_count", limit: 4
#   t.boolean "hidden",                      default: false, null: false
# end

# validates :text, :game_id, :submitted_by, presence: true
# validates :text, length: {in: 2..32}
# validates :hidden, inclusion: [true, false]

FactoryGirl.define do
  factory :tag do
    text { Faker::Commerce.product_name[1..32] }
    game_id { FactoryGirl.create(:game).id }
    submitted_by { FactoryGirl.create(:user).id }
  end
end
