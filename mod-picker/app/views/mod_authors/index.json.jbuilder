json.array!(@user_mod_author_maps) do |user_mod_author_map|
  json.extract! user_mod_author_map, :id, :mod_id, :user_id
  json.url user_mod_author_map_url(user_mod_author_map, format: :json)
end
