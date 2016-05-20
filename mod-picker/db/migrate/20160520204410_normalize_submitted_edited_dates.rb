class NormalizeSubmittedEditedDates < ActiveRecord::Migration
  def change
    # articles
    rename_column :articles, :created_at, :submitted
    rename_column :articles, :updated_at, :edited
    # base_reports
    rename_column :base_reports, :created_at, :submitted
    rename_column :base_reports, :updated_at, :edited
    # incorrect_notes
    rename_column :incorrect_notes, :created_at, :submitted
    rename_column :incorrect_notes, :updated_at, :edited
    # mod_lists
    rename_column :mod_lists, :created, :submitted
    rename_column :mod_lists, :completed, :edited
    # reports
    rename_column :reports, :created_at, :submitted
    rename_column :reports, :updated_at, :edited
  end
end
