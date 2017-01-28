class AddHelpVideoSections < ActiveRecord::Migration
  def change
    create_table "help_video_sections" do |t|
      t.integer :help_video_id, null: false
      t.integer :parent_id
      t.string :label, limit: 64, null: false
      t.string :description, limit: 255
      t.integer :seconds, limit: 3, null: false
    end

    add_foreign_key :help_video_sections, :help_videos
    add_foreign_key :help_video_sections, :help_video_sections, column: :parent_id
  end
end
