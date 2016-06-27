# create_table "mod_stars", id: false, force: :cascade do |t|
#     t.integer "mod_id",  limit: 4
#     t.integer "user_id", limit: 4
#   end

FactoryGirl.define do
  factory :mod_star do
    association :user
    association :mod
  end
  
end
