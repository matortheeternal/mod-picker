class AddGameIdToWorkshopInfos < ActiveRecord::Migration
  def change
    WorkshopInfo.delete_all
    add_column :workshop_infos, :game_id, :integer, null: false
  end
end
