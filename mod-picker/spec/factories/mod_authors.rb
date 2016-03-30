FactoryGirl.define do
  factory :mod_author do
    mod_id 1
    association :user, factory: :user
  end
end
