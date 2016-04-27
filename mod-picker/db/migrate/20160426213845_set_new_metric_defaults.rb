class SetNewMetricDefaults < ActiveRecord::Migration
  def change
    change_column :mods, :update_rate, :float, default: 0.0
    change_column :nexus_infos, :endorsement_rate, :float, default: 0.0
    change_column :nexus_infos, :dl_rate, :float, default: 0.0
    change_column :nexus_infos, :udl_to_endorsements, :float, default: 0.0
    change_column :nexus_infos, :udl_to_posts, :float, default: 0.0
    change_column :nexus_infos, :tdl_to_udl, :float, default: 0.0
    change_column :nexus_infos, :views_to_tdl, :float, default: 0.0
  end
end
