class FixReportsEditedColumn < ActiveRecord::Migration
  def change
    change_column :reports, :edited, :datetime, null: true
  end
end
