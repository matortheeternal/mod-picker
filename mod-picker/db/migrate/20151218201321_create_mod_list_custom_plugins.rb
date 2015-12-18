class CreateModListCustomPlugins < ActiveRecord::Migration
  def change
    create_table :mod_list_custom_plugins do |t|
      t.integer :ml_id
      t.boolean :active
      t.integer :load_order
      t.string :title
      t.text :description

      t.timestamps null: false
    end
  end
end
