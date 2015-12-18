class CreateUserModStarMaps < ActiveRecord::Migration
  def change
    create_table :user_mod_star_maps do |t|
      t.integer :mod_id
      t.integer :user_id

      t.timestamps null: false
    end
  end
end
