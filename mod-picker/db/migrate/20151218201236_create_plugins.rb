class CreatePlugins < ActiveRecord::Migration
  def change
    create_table :plugins do |t|
      t.integer :pl_id
      t.integer :mv_id
      t.text :filename
      t.text :author
      t.text :description
      t.string :hash

      t.timestamps null: false
    end
  end
end
