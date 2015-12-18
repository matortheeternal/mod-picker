class CreateModListComments < ActiveRecord::Migration
  def change
    create_table :mod_list_comments do |t|
      t.integer :ml_id
      t.integer :c_id

      t.timestamps null: false
    end
  end
end
