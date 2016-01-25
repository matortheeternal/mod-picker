json.array!(@override_records) do |override_record|
  json.extract! override_record, :id, :plugin_id, :master_id, :form_id
  json.url override_record_url(override_record, format: :json)
end
