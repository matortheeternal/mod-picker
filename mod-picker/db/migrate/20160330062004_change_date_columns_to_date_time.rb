class ChangeDateColumnsToDateTime < ActiveRecord::Migration
  def change
    change_column :comments, :submitted, :datetime
    change_column :comments, :edited, :datetime

    change_column :compatibility_notes, :submitted, :datetime
    change_column :compatibility_notes, :edited, :datetime

    change_column :installation_notes, :submitted, :datetime
    change_column :installation_notes, :edited, :datetime

    change_column :reviews, :submitted, :datetime
    change_column :reviews, :edited, :datetime

  end
end
