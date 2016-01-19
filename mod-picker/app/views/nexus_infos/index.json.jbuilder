json.array!(@nexus_infos) do |nexus_info|
  json.extract! nexus_info, :id, :nm_id, :mod_id, :uploaded_by, :authors, :endorsements, :total_downloads, :unique_downloads, :views, :posts_count, :videos_count, :images_count, :files_count, :articles_count, :nexus_category, :changelog
  json.url nexus_info_url(nexus_info, format: :json)
end
