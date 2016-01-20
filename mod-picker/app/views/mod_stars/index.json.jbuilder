json.array!(@mod_stars) do |mod_star|
  json.extract! mod_star, :id, :mod_id, :user_id
  json.url mod_star_url(mod_star, format: :json)
end
