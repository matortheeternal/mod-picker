json.array!(@lover_infos) do |lover_info|
  json.extract! lover_info, :id, :mod_id
  json.url lover_info_url(lover_info, format: :json)
end
