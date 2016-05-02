class AddHasStatsColumns < ActiveRecord::Migration
  def change
    add_column :nexus_infos, :has_stats, :boolean, default: false
    add_column :workshop_infos, :has_stats, :boolean, default: false
    add_column :lover_infos, :has_stats, :boolean, default: false
  end
end
