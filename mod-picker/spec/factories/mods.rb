FactoryGirl.define do
  factory :mod do
    association :game_id, factory: :game
    name { Faker::Lorem.words(3) }
    aliases { Faker::Lorem.characters(3) }
    is_utility false
    has_adult_content false
    association :primary_category_id, factory: :category
    association :secondary_category_id, factory: :category
    # primary_category_id { Category.offset(rand(Category.count)).first.id }
    # secondary_category_id { Category.offset(rand(Category.count)).first.id }

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
