json.array!(@incorrect_notes) do |incorrect_note|
  json.extract! incorrect_note, :id, :inc_id, :r_id, :cn_id, :in_id, :submitted_by, :reason
  json.url incorrect_note_url(incorrect_note, format: :json)
end
