class CreateModComments < ActiveRecord::Migration
  def change
    create_table :mod_comments do |t|
      t.integer :mod_id
      t.integer :c_id

      t.timestamps null: false
    end
  end
end
