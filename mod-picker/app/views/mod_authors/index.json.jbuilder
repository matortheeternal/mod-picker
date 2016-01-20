json.array!(@mod_authors) do |mod_author|
  json.extract! mod_author, :id, :mod_id, :user_id
  json.url mod_author_url(mod_author, format: :json)
end
