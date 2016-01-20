json.array!(@users) do |user|
  json.extract! user, :id, :username, :email, :user_level, :title, :avatar, :joined, :active_ml_id, :active_mc_id
  json.url user_url(user, format: :json)
end
