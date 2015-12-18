class CreateModListMods < ActiveRecord::Migration
  def change
    create_table :mod_list_mods do |t|
      t.integer :ml_id
      t.integer :mod_id
      t.boolean :active
      t.integer :install_order

      t.timestamps null: false
    end
  end
end
