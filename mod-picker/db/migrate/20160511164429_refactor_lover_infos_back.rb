class RefactorLoverInfosBack < ActiveRecord::Migration
  def change
    rename_column :lover_infos, :name, :mod_name
    rename_column :lover_infos, :submitted, :date_submitted
    rename_column :lover_infos, :updated, :date_updated
    rename_column :lover_infos, :size, :file_size
    rename_column :lover_infos, :version, :current_version
    rename_column :lover_infos, :is_adult, :has_adult_content
  end
end
