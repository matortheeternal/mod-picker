json.array!(@mod_lists) do |mod_list|
  json.extract! mod_list, :id, :ml_id, :game, :created_by, :is_collection, :is_public, :has_adult_content, :status, :created, :completed, :description
  json.url mod_list_url(mod_list, format: :json)
end
