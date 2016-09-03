class RenameTypeToReportType < ActiveRecord::Migration
  def change
    rename_column :reports, :type, :report_type
  end
end
