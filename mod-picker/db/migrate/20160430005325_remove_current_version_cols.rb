class RemoveCurrentVersionCols < ActiveRecord::Migration
  def change
    remove_column :lover_infos, :current_version
    remove_column :workshop_infos, :current_version
  end
end
