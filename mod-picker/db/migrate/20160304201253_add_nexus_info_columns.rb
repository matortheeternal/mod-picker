class AddNexusInfoColumns < ActiveRecord::Migration
  def change
    change_column :nexus_infos, :date_released, :datetime
    rename_column :nexus_infos, :date_released, :date_added
    change_column :nexus_infos, :date_updated, :datetime
    add_column :nexus_infos, :mod_name, :string
    add_column :nexus_infos, :current_version, :string
    add_column :nexus_infos, :last_scraped, :datetime
  end
end
