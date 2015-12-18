json.array!(@plugin_record_groups) do |plugin_record_group|
  json.extract! plugin_record_group, :id, :pl_id, :sig, :name, :new_records, :override_records
  json.url plugin_record_group_url(plugin_record_group, format: :json)
end
