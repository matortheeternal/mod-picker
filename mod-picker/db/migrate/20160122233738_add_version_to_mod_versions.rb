class AddVersionToModVersions < ActiveRecord::Migration
  def change
    add_column :mod_versions, :version, :string, limit: 16
  end
end
