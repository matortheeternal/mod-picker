class AddHelpVideos < ActiveRecord::Migration
  def change
    create_table "help_videos" do |t|
      t.integer "game_id"
      t.integer "category", limit: 1, default: 0, null: false
      t.integer "submitted_by", null: false
      t.string "youtube_id", limit: 16, null: false
      t.string "title", limit: 128, null: false
      t.text "text_body", null: false
      t.boolean "approved", default: false, null: false
      t.datetime "submitted", null: false
      t.datetime "edited"
    end

    add_column :games, :help_videos_count, :integer, default: 0, null: false, after: :help_pages_count

    add_foreign_key :help_videos, :games, column: "game_id"
    add_foreign_key :help_videos, :users, column: "submitted_by"
  end
end
