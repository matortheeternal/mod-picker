FactoryGirl.define do
  factory :comment do
    # submitted TimeDate.current; should be done in the model
    hidden false
    text_body { Faker::Lorem.sentence(4, false, 6) }
    association :user, factory: :user
    commentable_type "profile_comment"
  end
#  factory :comment do
#    id 1
#    parent_comment 1
#    submitted_by 1
#    hidden false
#    submitted "2016-01-19 01:14:24"
#    edited "2016-01-19 01:14:24"
#    text_body "MyText"
#  end
end
