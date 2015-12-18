json.array!(@mod_list_installation_notes) do |mod_list_installation_note|
  json.extract! mod_list_installation_note, :id, :ml_id, :in_id, :status
  json.url mod_list_installation_note_url(mod_list_installation_note, format: :json)
end
