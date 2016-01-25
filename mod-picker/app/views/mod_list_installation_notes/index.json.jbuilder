json.array!(@mod_list_installation_notes) do |mod_list_installation_note|
  json.extract! mod_list_installation_note, :id, :mod_list_id, :installation_note_id, :status
  json.url mod_list_installation_note_url(mod_list_installation_note, format: :json)
end
