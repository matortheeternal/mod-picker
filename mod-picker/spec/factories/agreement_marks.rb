FactoryGirl.define do
  factory :agreement_mark do
    association :correction, factory: :correction
    association :user, factory: :user 
    agree false
  end

end
