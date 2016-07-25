FactoryGirl.define do
  factory :mod do
    association :user, factory: :user
    name { Faker::App.name }
    aliases { Faker::Lorem.characters(3) }
    is_utility false
    has_adult_content false
    primary_category_id {FactoryGirl::create(:category).id}
    game_id {FactoryGirl::create(:game).id}
    released { DateTime.now }
    authors { Faker::Name.name }
  end
end
