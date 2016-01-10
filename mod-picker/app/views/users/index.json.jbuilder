json.array!(@users) do |user|
  json.extract! user, :id, :user_id, :username, :email, :user_level, :title, :avatar, :joined, :bio_id, :set_id, :rep_id, :active_ml_id, :active_mc_id
  json.url user_url(user, format: :json)
end
