json.array!(@user_reputations) do |user_reputation|
  json.extract! user_reputation, :id, :user_id, :overall, :offset, :audiovisual_design, :plugin_design, :utility_design, :script_design
  json.url user_reputation_url(user_reputation, format: :json)
end
