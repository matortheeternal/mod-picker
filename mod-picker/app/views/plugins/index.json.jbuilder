json.array!(@plugins) do |plugin|
  json.extract! plugin, :id, :pl_id, :mv_id, :filename, :author, :description, :crc_hash
  json.url plugin_url(plugin, format: :json)
end
