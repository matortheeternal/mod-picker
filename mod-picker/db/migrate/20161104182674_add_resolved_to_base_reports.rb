class AddResolvedToBaseReports < ActiveRecord::Migration
  def change
    add_column :base_reports, :resolved, :boolean, default: false, null: false, after: :reports_count
  end
end
