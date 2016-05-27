FactoryGirl.define do
  factory :mod do
    association :user, factory: :user
    name { Faker::App.name }
    aliases { Faker::Lorem.characters(3) }
    is_utility false
    has_adult_content false
    primary_category_id {FactoryGirl::create(:category).id}
    game_id {FactoryGirl::create(:game).id}

    factory :mod_with_versions do
      transient do
        mod_versions_count 1
      end

      after(:create) do |mod, evaluator|
        create_list(:mod_versions, evaluator.mod_versions_count, mod: mod)
      end
    end
  end
end
