class CreateUserModListStarMaps < ActiveRecord::Migration
  def change
    create_table :user_mod_list_star_maps do |t|
      t.integer :ml_id
      t.integer :user_id

      t.timestamps null: false
    end
  end
end
