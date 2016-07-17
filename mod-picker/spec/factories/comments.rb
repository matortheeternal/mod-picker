FactoryGirl.define do
  factory :comment do
    text_body { Faker::Lorem.sentence(4, false, 6) }
    association :user, factory: :user
    commentable_type "ModList"
    commentable_id { FactoryGirl.create(:mod_list).id }
    commentable { FactoryGirl.create(:mod_list) }
    hidden true
  end

  factory :comment_nil_hidden, parent: :comment do
    text_body { Faker::Lorem.sentence(4, false, 6) }
    association :user, factory: :user
    commentable_type "ModList"
    commentable_id 1
  end
end
