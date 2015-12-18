class CreateWorkshopInfos < ActiveRecord::Migration
  def change
    create_table :workshop_infos do |t|
      t.integer :ws_id

      t.timestamps null: false
    end
  end
end
