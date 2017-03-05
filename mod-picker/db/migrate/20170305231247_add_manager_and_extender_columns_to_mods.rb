class AddManagerAndExtenderColumnsToMods < ActiveRecord::Migration
  def change
    add_column :mods, :is_mod_manager, :bool, default: false, null: false, after: :is_utility
    add_column :mods, :is_extender, :bool, default: false, null: false, after: :is_mod_manager
  end
end
