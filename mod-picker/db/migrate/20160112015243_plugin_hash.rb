class PluginHash < ActiveRecord::Migration
  def change
    rename_column :plugins, :hash, :crc_hash
  end
end
