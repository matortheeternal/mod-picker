json.array!(@mod_comments) do |mod_comment|
  json.extract! mod_comment, :id, :mod_id, :comment_id
  json.url mod_comment_url(mod_comment, format: :json)
end
