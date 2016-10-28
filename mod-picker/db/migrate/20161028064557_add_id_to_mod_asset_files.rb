class AddIdToModAssetFiles < ActiveRecord::Migration
  def change
    add_column :mod_asset_files, :id, :primary_key
  end
end
