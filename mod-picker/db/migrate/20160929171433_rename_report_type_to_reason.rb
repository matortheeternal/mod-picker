class RenameReportTypeToReason < ActiveRecord::Migration
  def change
    rename_column :reports, :report_type, :reason
  end
end
