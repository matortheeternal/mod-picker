class CreateModAssetFiles < ActiveRecord::Migration
  def change
    create_table :mod_asset_files do |t|
      t.integer :maf_id
      t.string :filepath

      t.timestamps null: false
    end
  end
end
