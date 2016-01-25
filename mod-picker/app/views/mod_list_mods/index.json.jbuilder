json.array!(@mod_list_mods) do |mod_list_mod|
  json.extract! mod_list_mod, :id, :mod_list_id, :mod_id, :active, :install_order
  json.url mod_list_mod_url(mod_list_mod, format: :json)
end
