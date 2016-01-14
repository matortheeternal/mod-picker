json.array!(@installation_notes) do |installation_note|
  json.extract! installation_note, :id, :in_id, :submitted_by, :mv_id, :always, :note_type, :submitted, :edited, :text_body
  json.url installation_note_url(installation_note, format: :json)
end
