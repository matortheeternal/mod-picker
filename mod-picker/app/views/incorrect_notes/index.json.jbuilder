json.array!(@incorrect_notes) do |incorrect_note|
  json.extract! incorrect_note, :id, :review_id, :compatibility_note_id, :installation_note_id, :submitted_by, :reason
  json.url incorrect_note_url(incorrect_note, format: :json)
end
