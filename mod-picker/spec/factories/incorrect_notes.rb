FactoryGirl.define do
  factory :incorrect_note do
    association :user, factory: :user
    text_body { Faker::Lorem.sentence(5, false, 8) }
    correctable_id 1
    correctable_type "Filler"
    created_at Date.today
  end
end
