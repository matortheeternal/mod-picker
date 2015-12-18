class CreatePluginOverrideMaps < ActiveRecord::Migration
  def change
    create_table :plugin_override_maps do |t|
      t.integer :pl_id
      t.integer :mst_id
      t.integer :form_id
      t.string :sig
      t.text :name
      t.boolean :is_itm
      t.boolean :is_itpo
      t.boolean :is_udr

      t.timestamps null: false
    end
  end
end
