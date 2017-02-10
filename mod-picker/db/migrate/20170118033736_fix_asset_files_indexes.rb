class FixAssetFilesIndexes < ActiveRecord::Migration
  def change
    remove_index :asset_files, name: :filepath
    add_index :asset_files, [:game_id, :path], unique: true
  end
end
