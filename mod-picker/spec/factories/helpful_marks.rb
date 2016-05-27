FactoryGirl.define do
  factory :helpful_mark do
    association :user, factory: :user 
    helpful true
    helpfulable_id 1
    helpfulable_type "CompatibilityNote"
  end
end
