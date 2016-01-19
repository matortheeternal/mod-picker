json.array!(@category_priorities) do |category_priority|
  json.extract! category_priority, :id, :dominant_id, :recessive_id
  json.url category_priority_url(category_priority, format: :json)
end
