class CreateModVersions < ActiveRecord::Migration
  def change
    create_table :mod_versions do |t|
      t.integer :mv_id
      t.integer :mod_id
      t.datetime :released
      t.boolean :obsolete
      t.boolean :dangerous

      t.timestamps null: false
    end
  end
end
