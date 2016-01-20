json.array!(@reputation_maps) do |reputation_map|
  json.extract! reputation_map, :id, :from_rep_id, :to_rep_id
  json.url reputation_map_url(reputation_map, format: :json)
end
