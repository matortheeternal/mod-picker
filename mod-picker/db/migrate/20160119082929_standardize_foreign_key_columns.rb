class StandardizeForeignKeyColumns < ActiveRecord::Migration
  def change
    rename_column :agreement_marks, :inc_id, :incorrect_note_id

    rename_column :helpful_marks, :r_id, :review_id
    rename_column :helpful_marks, :cn_id, :compatibility_note_id
    rename_column :helpful_marks, :in_id, :installation_note_id

    rename_column :incorrect_notes, :r_id, :review_id
    rename_column :incorrect_notes, :cn_id, :compatibility_note_id
    rename_column :incorrect_notes, :in_id, :installation_note_id
    rename_column :installation_notes, :mv_id, :mod_version_id

    rename_column :masters, :pl_id, :plugin_id

    rename_column :mod_comments, :c_id, :comment_id

    rename_column :mod_list_comments, :ml_id, :mod_list_id
    rename_column :mod_list_comments, :c_id, :comment_id

    rename_column :mod_list_compatibility_notes, :ml_id, :mod_list_id
    rename_column :mod_list_compatibility_notes, :cn_id, :compatibility_note_id

    rename_column :mod_list_custom_plugins, :ml_id, :mod_list_id

    rename_column :mod_list_installation_notes, :ml_id, :mod_list_id
    rename_column :mod_list_installation_notes, :in_id, :installation_note_id

    rename_column :mod_list_mods, :ml_id, :mod_list_id

    rename_column :mod_list_plugins, :ml_id, :mod_list_id
    rename_column :mod_list_plugins, :pl_id, :plugin_id

    rename_column :mod_version_file_map, :mv_id, :mod_version_id
    rename_column :mod_version_file_map, :maf_id, :mod_asset_file_id

    rename_column :plugin_override_map, :pl_id, :plugin_id
    rename_column :plugin_override_map, :mst_id, :master_id

    rename_column :plugin_record_groups, :pl_id, :plugin_id

    rename_column :user_comments, :c_id, :comment_id

    rename_column :user_mod_list_star_map, :ml_id, :mod_list_id
  end
end
