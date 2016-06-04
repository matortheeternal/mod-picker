FactoryGirl.define do
  factory :correction do
    association :user, factory: :user

    text_body      { Faker::Lorem.sentence(20, false, 20) }
    correctable_id { FactoryGirl.create(:install_order_note).id }
    association :game, factory: :game
    # game_id        { FactoryGirl.create(:game).id }
    title { Faker::Name.name }
    correctable_type "InstallOrderNote"
  end
end
