json.array!(@masters) do |master|
  json.extract! master, :id, :mst_id, :pl_id
  json.url master_url(master, format: :json)
end
