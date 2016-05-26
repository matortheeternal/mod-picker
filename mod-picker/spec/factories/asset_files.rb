FactoryGirl.define do
  factory :asset_file do
    filepath { Faker::Lorem.word }
    game_id { FactoryGirl.create(:game).id }
  end
end