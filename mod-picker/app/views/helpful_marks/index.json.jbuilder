json.array!(@helpful_marks) do |helpful_mark|
  json.extract! helpful_mark, :id, :review_id, :compatibility_note_id, :installation_note_id, :submitted_by, :helpful
  json.url helpful_mark_url(helpful_mark, format: :json)
end
