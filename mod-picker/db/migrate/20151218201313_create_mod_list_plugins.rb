class CreateModListPlugins < ActiveRecord::Migration
  def change
    create_table :mod_list_plugins do |t|
      t.integer :ml_id
      t.integer :pl_id
      t.boolean :active
      t.integer :load_order

      t.timestamps null: false
    end
  end
end
