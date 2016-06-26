class NormalizeSubmittedEditedDates < ActiveRecord::Migration
  def change
    # articles
    rename_column :articles, :created_at, :submitted
    rename_column :articles, :updated_at, :edited
    # base_reports
    rename_column :base_reports, :created_at, :submitted
    rename_column :base_reports, :updated_at, :edited
    # corrections
    rename_column :corrections, :created_at, :submitted
    rename_column :corrections, :updated_at, :edited
    # mod_lists
    rename_column :mod_lists, :created, :submitted
    rename_column :mod_lists, :completed, :edited
    # reports
    rename_column :reports, :created_at, :submitted
    rename_column :reports, :updated_at, :edited
  end
end
