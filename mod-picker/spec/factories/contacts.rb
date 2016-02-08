FactoryGirl.define do
  factory :contact do
    firstname "John"
    lastname "Doe"
    sequence(:email) { |n| "misaka#{n}@example.com"}
  end
end
