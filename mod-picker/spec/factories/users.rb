FactoryGirl.define do
  factory :user do
    username { Faker::Internet.user_name }
    user_level "user"
    encrypted_password { Faker::Internet.password }
    email   { Faker::Internet.email }
    password { Faker::Internet.password }
  end
end
