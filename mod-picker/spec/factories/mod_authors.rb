FactoryGirl.define do
  factory :mod_author do
    # the association is named :author because the association name is :author
    # while the table associated with :author is really just a :user table.
    # This can be seen in the mod_author model file.
    association :author, factory: :user
    mod_id 1
  end
end
