json.array!(@mod_list_comments) do |mod_list_comment|
  json.extract! mod_list_comment, :id, :ml_id, :c_id
  json.url mod_list_comment_url(mod_list_comment, format: :json)
end
