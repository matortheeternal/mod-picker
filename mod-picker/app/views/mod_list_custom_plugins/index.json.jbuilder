json.array!(@mod_list_custom_plugins) do |mod_list_custom_plugin|
  json.extract! mod_list_custom_plugin, :id, :ml_id, :active, :load_order, :title, :description
  json.url mod_list_custom_plugin_url(mod_list_custom_plugin, format: :json)
end
