json.array!(@mod_asset_files) do |mod_asset_file|
  json.extract! mod_asset_file, :id, :maf_id, :filepath
  json.url mod_asset_file_url(mod_asset_file, format: :json)
end
