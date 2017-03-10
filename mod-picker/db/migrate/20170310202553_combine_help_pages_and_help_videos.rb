class CombineHelpPagesAndHelpVideos < ActiveRecord::Migration
  def change
    add_column :help_pages, :youtube_id, :string, limit: 16, after: :submitted_by
    remove_foreign_key :help_video_sections, column: :help_video_id
    remove_index :help_video_sections, name: "fk_rails_edd4587296"
    rename_column :help_video_sections, :help_video_id, :help_page_id
    add_foreign_key :help_video_sections, :help_pages
    drop_table :help_videos
  end
end
