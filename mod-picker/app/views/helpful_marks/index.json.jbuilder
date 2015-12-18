json.array!(@helpful_marks) do |helpful_mark|
  json.extract! helpful_mark, :id, :r_id, :cn_id, :in_id, :submitted_by, :helpful
  json.url helpful_mark_url(helpful_mark, format: :json)
end
