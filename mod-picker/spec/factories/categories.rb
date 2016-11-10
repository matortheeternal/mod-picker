# create_table "categories", force: :cascade do |t|
#     t.integer "parent_id",   limit: 4
#     t.string  "name",        limit: 64
#     t.string  "description", limit: 255
#   end

#   add_index "categories", ["parent_id"], name: "fk_rails_82f48f7407", using: :btree

FactoryGirl.define do
  factory :category, aliases: [:primary_category_id, :secondary_category_id]do
    name { Faker::Company.buzzword }
    description { Faker::Lorem.sentence(3) }
  end
  
end
