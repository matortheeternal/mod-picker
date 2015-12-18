class CreateMasters < ActiveRecord::Migration
  def change
    create_table :masters do |t|
      t.integer :mst_id
      t.integer :pl_id

      t.timestamps null: false
    end
  end
end
