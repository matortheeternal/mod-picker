class SetNexusInfoStatisticDefaults < ActiveRecord::Migration
  def change
    change_column :nexus_infos, :endorsements, :integer, default: 0
    change_column :nexus_infos, :total_downloads, :integer, default: 0
    change_column :nexus_infos, :unique_downloads, :integer, default: 0
    change_column :nexus_infos, :views, :integer,  default: 0
    change_column :nexus_infos, :posts_count, :integer, default: 0
    change_column :nexus_infos, :videos_count, :integer, default: 0
    change_column :nexus_infos, :images_count, :integer, default: 0
    change_column :nexus_infos, :files_count, :integer, default: 0
    change_column :nexus_infos, :articles_count, :integer, default: 0
  end
end
