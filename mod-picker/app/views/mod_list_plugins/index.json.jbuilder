json.array!(@mod_list_plugins) do |mod_list_plugin|
  json.extract! mod_list_plugin, :id, :mod_list_id, :plugin_id, :active, :load_order
  json.url mod_list_plugin_url(mod_list_plugin, format: :json)
end
