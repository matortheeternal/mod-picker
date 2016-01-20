json.array!(@plugin_overrides) do |plugin_override|
  json.extract! plugin_override, :id, :plugin_id, :master_id, :form_id
  json.url plugin_override_url(plugin_override, format: :json)
end
