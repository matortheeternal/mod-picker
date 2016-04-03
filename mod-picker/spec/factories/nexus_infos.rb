FactoryGirl.define do
  factory :nexus_info do
    id 1
    game_id 1
    uploaded_by { Faker::Internet.user_name }
    authors { Faker::Internet.user_name }
    total_downloads { Faker::Number.between(1000, 2000000) }
    unique_downloads { Faker::Number.between(100, 1000000) }
    endorsements { Faker::Number.between(50, 100000) }
    views { Faker::Number.between(1000, 10000000) }
    posts_count { Faker::Number.between(1, 50000) }
    videos_count { Faker::Number.between(1, 10) }
    images_count { Faker::Number.between(1, 100) }
    files_count { Faker::Number.between(1, 40) }
    articles_count { Faker::Number.between(0, 6) }
    nexus_category { Faker::Number.between(1, 100) }
  end
end
