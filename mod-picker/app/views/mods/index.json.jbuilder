json.array!(@mods) do |mod|
  json.extract! mod, :id, :mod_id, :game, :name, :aliases, :is_utility, :category, :has_adult_content, :nm_id, :ws_id, :ll_id
  json.url mod_url(mod, format: :json)
end
