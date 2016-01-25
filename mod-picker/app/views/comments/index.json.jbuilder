json.array!(@comments) do |comment|
  json.extract! comment, :id, :parent_comment, :submitted_by, :hidden, :submitted, :edited, :text_body
  json.url comment_url(comment, format: :json)
end
