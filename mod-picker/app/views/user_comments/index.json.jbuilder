json.array!(@user_comments) do |user_comment|
  json.extract! user_comment, :id, :user_id, :c_id
  json.url user_comment_url(user_comment, format: :json)
end
