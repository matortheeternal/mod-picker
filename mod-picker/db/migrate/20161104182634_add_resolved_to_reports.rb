class AddResolvedToReports < ActiveRecord::Migration
  def change
    add_column :reports, :resolved, :boolean, default: false, null: false, after: :note
  end
end
