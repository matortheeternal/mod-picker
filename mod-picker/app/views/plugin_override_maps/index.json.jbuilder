json.array!(@plugin_override_maps) do |plugin_override_map|
  json.extract! plugin_override_map, :id, :plugin_id, :master_id, :form_id
  json.url plugin_override_map_url(plugin_override_map, format: :json)
end
