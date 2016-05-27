class AddMissingWorkshopStats < ActiveRecord::Migration
  def change
    add_column :workshop_infos, :images_count, :integer, default: 0
    add_column :workshop_infos, :videos_count, :integer, default: 0
  end
end
