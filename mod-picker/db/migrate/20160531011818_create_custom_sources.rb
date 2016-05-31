class CreateCustomSources < ActiveRecord::Migration
  def change
    create_table :custom_sources do |t|
      t.integer :mod_id, null: false
      t.string :label
      t.string :url, null: false
    end

    add_foreign_key :custom_sources, :mods
  end
end
