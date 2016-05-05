class RenamePluginColumns < ActiveRecord::Migration
  def change
    rename_column :plugins, :new_records, :record_count
    rename_column :plugins, :override_records, :override_count
    rename_column :plugin_record_groups, :signature, :sig
    rename_column :plugin_record_groups, :new_records, :record_count
    rename_column :plugin_record_groups, :override_records, :override_count
    rename_column :override_records, :form_id, :fid
    rename_column :override_records, :signature, :sig
  end
end
