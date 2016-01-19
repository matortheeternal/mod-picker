json.array!(@mods) do |mod|
  json.extract! mod, :id, :mod_id, :game_id, :name, :aliases, :is_utility, :has_adult_content, :primary_category_id, :secondary_category_id
  json.url mod_url(mod, format: :json)
end
