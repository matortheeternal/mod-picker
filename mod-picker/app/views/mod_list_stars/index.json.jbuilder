json.array!(@mod_list_stars) do |mod_list_star|
  json.extract! mod_list_star, :id, :mod_list_id, :user_id
  json.url mod_list_star_url(mod_list_star, format: :json)
end
