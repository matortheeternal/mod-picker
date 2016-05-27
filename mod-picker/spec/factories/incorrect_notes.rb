FactoryGirl.define do
  factory :incorrect_note do
    association :user, factory: :user
    text_body { Faker::Lorem.sentence(20, false, 20) }
    correctable_id 1
    correctable_type "InstallOrderNote"
  end
end
