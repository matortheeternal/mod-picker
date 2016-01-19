json.array!(@plugins) do |plugin|
  json.extract! plugin, :id, :mod_version_id, :filename, :author, :description, :hash
  json.url plugin_url(plugin, format: :json)
end
