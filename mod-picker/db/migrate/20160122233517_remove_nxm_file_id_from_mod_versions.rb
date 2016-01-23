class RemoveNxmFileIdFromModVersions < ActiveRecord::Migration
  def change
    remove_column :mod_versions, :nxm_file_id
  end
end
