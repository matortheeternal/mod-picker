class ChangeDateToDateTimeOnModList < ActiveRecord::Migration
  def change
    change_column :mod_lists, :created, :datetime
    change_column :mod_lists, :completed, :datetime
  end
end
