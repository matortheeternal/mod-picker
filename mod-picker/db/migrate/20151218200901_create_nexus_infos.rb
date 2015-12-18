class CreateNexusInfos < ActiveRecord::Migration
  def change
    create_table :nexus_infos do |t|
      t.integer :nm_id
      t.text :uploaded_by
      t.text :authors
      t.integer :endorsements
      t.integer :total_downloads
      t.integer :unique_downloads
      t.integer :views
      t.integer :posts_count
      t.integer :videos_count
      t.integer :images_count
      t.integer :files_count
      t.integer :articles_count
      t.integer :nexus_category
      t.text :changelog

      t.timestamps null: false
    end
  end
end
