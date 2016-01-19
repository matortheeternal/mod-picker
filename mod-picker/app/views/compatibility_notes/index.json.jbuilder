json.array!(@compatibility_notes) do |compatibility_note|
  json.extract! compatibility_note, :id, :submitted_by, :mod_mode, :compatibility_patch, :compatibility_status
  json.url compatibility_note_url(compatibility_note, format: :json)
end
