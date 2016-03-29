class RemoveChangelogColumnFromNexusInfos < ActiveRecord::Migration
  def change
    remove_column :nexus_infos, :changelog
  end
end
