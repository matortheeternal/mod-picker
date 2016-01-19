json.array!(@mod_list_comments) do |mod_list_comment|
  json.extract! mod_list_comment, :id, :mod_list_id, :comment_id
  json.url mod_list_comment_url(mod_list_comment, format: :json)
end
