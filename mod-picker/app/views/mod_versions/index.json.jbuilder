json.array!(@mod_versions) do |mod_version|
  json.extract! mod_version, :id, :mod_id, :version, :released, :obsolete, :dangerous
  json.url mod_version_url(mod_version, format: :json)
end
