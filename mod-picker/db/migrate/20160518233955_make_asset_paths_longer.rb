class MakeAssetPathsLonger < ActiveRecord::Migration
  def change
    change_column :asset_files, :filepath, :string, limit: 255
  end
end
