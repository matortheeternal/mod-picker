json.array!(@reputation_links) do |reputation_link|
  json.extract! reputation_link, :id, :from_rep_id, :to_rep_id
  json.url reputation_link_url(reputation_link, format: :json)
end
