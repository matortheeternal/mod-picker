json.array!(@user_mod_star_maps) do |user_mod_star_map|
  json.extract! user_mod_star_map, :id, :mod_id, :user_id
  json.url user_mod_star_map_url(user_mod_star_map, format: :json)
end
