json.array!(@user_bios) do |user_bio|
  json.extract! user_bio, :id, :user_id, :nexus_username, :nexus_verified, :lover_username, :lover_verified, :steam_username, :steam_verified
  json.url user_bio_url(user_bio, format: :json)
end
