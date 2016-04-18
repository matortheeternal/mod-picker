FactoryGirl.define do
  factory :compatibility_note do
    association :user, factory: :user
    compatibility_type "incompatible"
    text_body { Faker::Lorem.sentence(20, false, 6) }
  end
end
