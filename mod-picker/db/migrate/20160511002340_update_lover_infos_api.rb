class UpdateLoverInfosApi < ActiveRecord::Migration
  def change
    rename_column :lover_infos, :mod_name, :name
    rename_column :lover_infos, :date_submitted, :submitted
    rename_column :lover_infos, :date_updated, :updated
    add_column :lover_infos, :version, :string, limit: 32
    rename_column :lover_infos, :file_size, :size
    add_column :lover_infos, :is_adult, :boolean
  end
end
