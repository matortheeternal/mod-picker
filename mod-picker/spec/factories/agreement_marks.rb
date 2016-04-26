FactoryGirl.define do
  factory :agreement_mark do
    association :incorrect_note, factory: :incorrect_note
    association :user, factory: :user 
    agree false
  end

end
