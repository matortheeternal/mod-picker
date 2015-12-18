json.array!(@comments) do |comment|
  json.extract! comment, :id, :c_id, :parent_comment, :submitted_by, :hidden, :submitted, :edited
  json.url comment_url(comment, format: :json)
end
