class ChangeDateColumnsToDatetime < ActiveRecord::Migration
  def change
    change_column :compatibility_notes, :submitted, :datetime
    change_column :compatibility_notes, :edited, :datetime

    change_column :mod_lists, :created, :datetime
    change_column :mod_lists, :completed, :datetime

    change_column :mod_versions, :released, :datetime

    change_column :reviews, :submitted, :datetime
    change_column :reviews, :edited, :datetime
  end
end
