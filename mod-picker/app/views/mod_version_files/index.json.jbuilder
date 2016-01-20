json.array!(@mod_version_files) do |mod_version_file|
  json.extract! mod_version_file, :id, :mod_version_id, :mod_asset_file_id
  json.url mod_version_file_url(mod_version_file, format: :json)
end
