class AddExtraModMetrics < ActiveRecord::Migration
  def change
    add_column :mods, :released, :datetime
    add_column :mods, :update_rate, :float
    add_column :nexus_infos, :endorsement_rate, :float
    add_column :nexus_infos, :dl_rate, :float
    add_column :nexus_infos, :udl_to_endorsements, :float
    add_column :nexus_infos, :udl_to_posts, :float
    add_column :nexus_infos, :tdl_to_udl, :float
    add_column :nexus_infos, :views_to_tdl, :float
  end
end
