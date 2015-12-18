class CreateModVersionFileMaps < ActiveRecord::Migration
  def change
    create_table :mod_version_file_maps do |t|
      t.integer :mv_id
      t.integer :maf_id

      t.timestamps null: false
    end
  end
end
