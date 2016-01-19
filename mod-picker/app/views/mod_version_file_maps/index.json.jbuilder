json.array!(@mod_version_file_maps) do |mod_version_file_map|
  json.extract! mod_version_file_map, :id, :mod_version_id, :mod_asset_file_id
  json.url mod_version_file_map_url(mod_version_file_map, format: :json)
end
