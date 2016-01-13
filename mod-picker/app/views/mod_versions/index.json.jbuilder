json.array!(@mod_versions) do |mod_version|
  json.extract! mod_version, :id, :mv_id, :mod_id, :nxm_file_id, :released, :obsolete, :dangerous
  json.url mod_version_url(mod_version, format: :json)
end
