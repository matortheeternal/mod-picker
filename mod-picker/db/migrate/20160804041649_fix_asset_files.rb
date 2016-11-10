class FixAssetFiles < ActiveRecord::Migration
  def change
    rename_column :asset_files, :filepath, :path
    add_column :mod_asset_files, :subpath, :string
    change_column :mod_asset_files, :asset_file_id, :integer, null: true
  end
end
