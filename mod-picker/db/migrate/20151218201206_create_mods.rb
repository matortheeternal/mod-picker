class CreateMods < ActiveRecord::Migration
  def change
    create_table :mods do |t|
      t.integer :mod_id
      t.text :game
      t.text :name
      t.text :aliases
      t.boolean :is_utility
      t.integer :category
      t.boolean :has_adult_content
      t.integer :nm_id
      t.integer :ws_id
      t.integer :ll_id

      t.timestamps null: false
    end
  end
end
