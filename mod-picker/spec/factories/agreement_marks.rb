FactoryGirl.define do
  factory :agreement_mark do
    association :incorrect_note, factory: :incorrect_note
    submitted_by 1
    agree false
  end

end
