json.array!(@masters) do |master|
  json.extract! master, :id, :plugin_id
  json.url master_url(master, format: :json)
end
