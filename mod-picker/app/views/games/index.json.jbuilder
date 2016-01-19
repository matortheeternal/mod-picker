json.array!(@games) do |game|
  json.extract! game, :id, :id, :short_name, :long_name, :abbr_name, :exe_name, :steam_app_ids
  json.url game_url(game, format: :json)
end
