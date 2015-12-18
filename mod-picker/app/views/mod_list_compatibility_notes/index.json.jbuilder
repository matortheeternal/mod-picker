json.array!(@mod_list_compatibility_notes) do |mod_list_compatibility_note|
  json.extract! mod_list_compatibility_note, :id, :ml_id, :cn_id, :status
  json.url mod_list_compatibility_note_url(mod_list_compatibility_note, format: :json)
end
