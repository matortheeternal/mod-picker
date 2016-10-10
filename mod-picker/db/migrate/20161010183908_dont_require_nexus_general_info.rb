class DontRequireNexusGeneralInfo < ActiveRecord::Migration
  def change
    change_column :nexus_infos, :mod_name, :string, null: true
    change_column :nexus_infos, :authors, :string, limit: 128, null: true
    change_column :nexus_infos, :released, :datetime, null: true
  end
end
