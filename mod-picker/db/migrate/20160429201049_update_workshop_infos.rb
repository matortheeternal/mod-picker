class UpdateWorkshopInfos < ActiveRecord::Migration
  def change
    change_table :workshop_infos do |t|
      # basic columns
      t.column :mod_name, :string
      t.column :uploaded_by, :string, limit: 128
      t.column :date_submitted, :string
      t.column :date_updated, :string
      t.column :current_version, :string, limit: 32
      t.column :last_scraped, :datetime

      # statistics columns
      t.column :discussions_count, :integer, default: 0
      t.column :comments_count, :integer, default: 0
      t.column :ratings_count, :integer, default: 0
      t.column :average_rating, :integer, limit: 1, default: 0
      t.column :views, :integer, default: 0
      t.column :subscribers, :integer, default: 0
      t.column :favorites, :integer, default: 0
      t.column :file_size, :integer, default: 0
    end

    add_foreign_key :workshop_infos, :mods, column: :mod_id
  end
end
