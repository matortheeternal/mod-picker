class CreateLoverInfos < ActiveRecord::Migration
  def change
    create_table :lover_infos do |t|
      t.integer :ll_id

      t.timestamps null: false
    end
  end
end
