class SetTagCounterCacheDefaults < ActiveRecord::Migration
  def change
    change_column :tags, :mods_count, :integer, default: 0
    change_column :tags, :mod_lists_count, :integer, default: 0
  end
end
