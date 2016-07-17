FactoryGirl.define do
  factory :correction do
    association :user, factory: :user
    # For future reference, if a field is set to default none, null: false
    # that means that field is validated to need to existence in sql
    game_id { FactoryGirl.create(:game).id }
    text_body { Faker::Lorem.sentence(20, false, 20) }
    correctable_id { FactoryGirl.create(:install_order_note).id }
    correctable_type "InstallOrderNote"
    title { Faker::Lorem.word }
  end
end
