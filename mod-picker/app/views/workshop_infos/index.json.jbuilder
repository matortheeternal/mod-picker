json.array!(@workshop_infos) do |workshop_info|
  json.extract! workshop_info, :id, :ws_id, :mod_id
  json.url workshop_info_url(workshop_info, format: :json)
end
