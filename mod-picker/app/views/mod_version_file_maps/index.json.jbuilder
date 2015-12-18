json.array!(@mod_version_file_maps) do |mod_version_file_map|
  json.extract! mod_version_file_map, :id, :mv_id, :maf_id
  json.url mod_version_file_map_url(mod_version_file_map, format: :json)
end
