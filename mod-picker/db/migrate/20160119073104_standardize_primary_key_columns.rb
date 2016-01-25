class StandardizePrimaryKeyColumns < ActiveRecord::Migration
  def change
    rename_column :nexus_infos, :nm_id, :id
    rename_column :workshop_infos, :ws_id, :id
    rename_column :lover_infos, :ll_id, :id
    rename_column :mods, :mod_id, :id
    rename_column :mod_versions, :mv_id, :id
    rename_column :mod_asset_files, :maf_id, :id
    rename_column :plugins, :pl_id, :id
    rename_column :masters, :mst_id, :id
    rename_column :mod_lists, :ml_id, :id
    rename_column :users, :user_id, :id
    rename_column :user_bios, :bio_id, :id
    rename_column :user_settings, :set_id, :id
    rename_column :user_reputations, :rep_id, :id
    rename_column :comments, :c_id, :id
    rename_column :reviews, :r_id, :id
    rename_column :installation_notes, :in_id, :id
    rename_column :compatibility_notes, :cn_id, :id
    rename_column :incorrect_notes, :inc_id, :id
  end
end
